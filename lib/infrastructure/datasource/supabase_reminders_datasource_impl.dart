import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vita_habit/domain/datasources/reminders_datasource.dart';
import 'package:vita_habit/domain/entities/reminder.dart';
import 'package:vita_habit/infrastructure/mappers/reminder_mapper.dart';

class SupabaseRemindersDatasourceImpl implements RemindersDatasource {
  final SupabaseClient _client;

  SupabaseRemindersDatasourceImpl(this._client);

  String get _userId => _client.auth.currentUser!.id;

  @override
  Future<List<Reminder>> getAll() async {
    final rows = await _client
        .from('reminders')
        .select()
        .eq('user_id', _userId)
        .order('date', ascending: true);

    return rows.map<Reminder>(ReminderMapper.fromSupabase).toList();
  }

  @override
  Future<List<Reminder>> getByDate(DateTime date) async {
    final dateStr = '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    final rows = await _client
        .from('reminders')
        .select()
        .eq('user_id', _userId)
        .eq('date', dateStr)
        .order('time_of_day', ascending: true);

    return rows.map<Reminder>(ReminderMapper.fromSupabase).toList();
  }

  @override
  Future<Reminder> create(Reminder reminder) async {
    final data = ReminderMapper.toSupabase(reminder, _userId);
    final row = await _client
        .from('reminders')
        .insert(data)
        .select()
        .single();

    return ReminderMapper.fromSupabase(row);
  }

  @override
  Future<void> delete(String id) async {
    await _client
        .from('reminders')
        .delete()
        .eq('id', id)
        .eq('user_id', _userId);
  }
}
