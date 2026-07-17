import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vita_habit/domain/datasources/habits_datasource.dart';
import 'package:vita_habit/domain/entities/habit.dart';
import 'package:vita_habit/infrastructure/mappers/habit_mapper.dart';

class SupabaseHabitsDatasourceImpl implements HabitsDatasource {
  final SupabaseClient _client;

  SupabaseHabitsDatasourceImpl(this._client);

  String get _userId => _client.auth.currentUser!.id;

  @override
  Future<List<Habit>> getTodayHabits() async {
    final rows = await _client
        .from('habits')
        .select()
        .eq('user_id', _userId)
        .order('created_at', ascending: true);

    final habits = rows.map<Habit>(HabitMapper.fromSupabase).toList();

    // Si algún hábito no fue reseteado hoy, resetear en BD
    final today = _todayStr();
    final toReset = rows.where(
      (r) => (r['last_reset_date'] as String?) != today,
    );
    for (final row in toReset) {
      await _client
          .from('habits')
          .update({
            'current_value': 0,
            'is_active': false,
            'last_reset_date': today,
          })
          .eq('id', row['id'] as String);
    }

    return habits;
  }

  @override
  Future<List<Habit>> getAllHabits() => getTodayHabits();

  @override
  Future<Habit> updateProgress(String habitId, double newValue) async {
    final row = await _client
        .from('habits')
        .update({'current_value': newValue, 'last_reset_date': _todayStr()})
        .eq('id', habitId)
        .eq('user_id', _userId)
        .select()
        .single();

    return HabitMapper.fromSupabase(row);
  }

  @override
  Future<Habit> toggleActive(String habitId) async {
    // Leer estado actual
    final current = await _client
        .from('habits')
        .select('is_active')
        .eq('id', habitId)
        .eq('user_id', _userId)
        .single();

    final row = await _client
        .from('habits')
        .update({'is_active': !(current['is_active'] as bool)})
        .eq('id', habitId)
        .eq('user_id', _userId)
        .select()
        .single();

    return HabitMapper.fromSupabase(row);
  }

  @override
  Future<void> saveHabit(Habit habit) async {
    final data = HabitMapper.toSupabase(habit, _userId);

    if (habit.id.isEmpty) {
      // INSERT: deja que Supabase genere el UUID con gen_random_uuid()
      await _client.from('habits').insert(data);
    } else {
      // UPDATE de un hábito existente
      await _client
          .from('habits')
          .update(data)
          .eq('id', habit.id)
          .eq('user_id', _userId);
    }
  }

  @override
  Future<void> deleteHabit(String habitId) async {
    await _client
        .from('habits')
        .delete()
        .eq('id', habitId)
        .eq('user_id', _userId);
  }

  // ── Helper ──────────────────────────────────────────────────────────────
  String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }
}
