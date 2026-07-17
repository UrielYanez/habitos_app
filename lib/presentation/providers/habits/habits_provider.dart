import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:vita_habit/domain/entities/habit.dart';
import 'package:vita_habit/infrastructure/datasource/supabase_habits_datasource_impl.dart';
import 'package:vita_habit/infrastructure/repositories/habits_repository_impl.dart';
import 'package:vita_habit/presentation/providers/auth/auth_provider.dart';
import 'package:vita_habit/infrastructure/services/notifications_service.dart';

// ── Repositorio ────────────────────────────────────────────────────────────
final habitsRepositoryProvider = Provider((ref) {
  final client = ref.watch(supabaseClientProvider);
  return HabitsRepositoryImpl(SupabaseHabitsDatasourceImpl(client));
});

// ── Notifier ───────────────────────────────────────────────────────────────
class HabitsNotifier extends StateNotifier<AsyncValue<List<Habit>>> {
  HabitsNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadHabits();
  }

  final Ref _ref;

  Future<void> loadHabits() async {
    state = const AsyncValue.loading();
    try {
      final habits = await _ref.read(habitsRepositoryProvider).getTodayHabits();
      state = AsyncValue.data(habits);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleActive(String habitId) async {
    try {
      final updated = await _ref
          .read(habitsRepositoryProvider)
          .toggleActive(habitId);
      state = state.whenData(
        (list) => list.map((h) => h.id == habitId ? updated : h).toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createHabit({
    required String name,
    required HabitCategory category,
    required double goalValue,
    required HabitUnit unit,
    DateTime? scheduledTime,
  }) async {
    try {
      final habit = Habit(
        id: '', // Supabase genera el UUID con gen_random_uuid()
        name: name,
        category: category,
        goalValue: goalValue,
        unit: unit,
        scheduledTime: scheduledTime,
      );
      await _ref.read(habitsRepositoryProvider).saveHabit(habit);

      if (scheduledTime != null) {
        await NotificationsService.scheduleDailyNotification(
          id: habit.name.hashCode, // Temporal para la notificacion local
          title: '¡Hora de tu hábito!',
          body: 'No olvides: $name',
          scheduledDate: scheduledTime,
        );
      }

      await loadHabits(); // recarga para obtener el UUID real de BD
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateProgress(String habitId, double newValue) async {
    try {
      final updated = await _ref
          .read(habitsRepositoryProvider)
          .updateProgress(habitId, newValue);
      state = state.whenData(
        (list) => list.map((h) => h.id == habitId ? updated : h).toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteHabit(String habitId) async {
    try {
      await _ref.read(habitsRepositoryProvider).deleteHabit(habitId);
      state = state.whenData(
        (list) => list.where((h) => h.id != habitId).toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final habitsProvider =
    StateNotifierProvider<HabitsNotifier, AsyncValue<List<Habit>>>(
      (ref) => HabitsNotifier(ref),
    );

// ── Providers derivados ────────────────────────────────────────────────────
final pendingHabitsProvider = Provider<List<Habit>>((ref) {
  return ref
      .watch(habitsProvider)
      .maybeWhen(
        data: (list) => list.where((h) => !h.isCompleted).toList(),
        orElse: () => [],
      );
});

final completedHabitsProvider = Provider<List<Habit>>((ref) {
  return ref
      .watch(habitsProvider)
      .maybeWhen(
        data: (list) => list.where((h) => h.isCompleted).toList(),
        orElse: () => [],
      );
});

final activeStreakProvider = Provider<int>((ref) {
  return ref
      .watch(habitsProvider)
      .maybeWhen(
        data: (habits) => habits.isNotEmpty ? habits.first.streakDays : 0,
        orElse: () => 0,
      );
});

final nextHabitProvider = Provider<Habit?>((ref) {
  return ref
      .watch(habitsProvider)
      .maybeWhen(
        data: (list) {
          final pending =
              list
                  .where((h) => !h.isCompleted && h.scheduledTime != null)
                  .toList()
                ..sort((a, b) => a.scheduledTime!.compareTo(b.scheduledTime!));
          return pending.isNotEmpty ? pending.first : null;
        },
        orElse: () => null,
      );
});
