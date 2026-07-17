import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:vita_habit/domain/entities/reminder.dart';
import 'package:vita_habit/infrastructure/datasource/supabase_reminders_datasource_impl.dart';
import 'package:vita_habit/infrastructure/repositories/reminders_repository_impl.dart';
import 'package:vita_habit/presentation/providers/auth/auth_provider.dart';

// ── Repositorio ────────────────────────────────────────────────────────────
final remindersRepositoryProvider = Provider((ref) {
  final client = ref.watch(supabaseClientProvider);
  return RemindersRepositoryImpl(SupabaseRemindersDatasourceImpl(client));
});

// ── Notifier ───────────────────────────────────────────────────────────────
class RemindersNotifier extends StateNotifier<AsyncValue<List<Reminder>>> {
  RemindersNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadAll();
  }

  final Ref _ref;

  Future<void> loadAll() async {
    state = const AsyncValue.loading();
    try {
      final repo = _ref.read(remindersRepositoryProvider);
      final reminders = await repo.getAll();
      state = AsyncValue.data(reminders);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addReminder(Reminder reminder) async {
    try {
      final repo = _ref.read(remindersRepositoryProvider);
      final created = await repo.create(reminder);
      state = state.whenData((list) => [...list, created]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> removeReminder(String id) async {
    try {
      final repo = _ref.read(remindersRepositoryProvider);
      await repo.delete(id);
      state = state.whenData((list) => list.where((r) => r.id != id).toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // ── Métodos síncronos sobre el estado en memoria ─────────────────────────
  List<Reminder> forDay(DateTime day) {
    return state.maybeWhen(
      data: (list) =>
          list
              .where(
                (r) =>
                    r.date.year == day.year &&
                    r.date.month == day.month &&
                    r.date.day == day.day,
              )
              .toList()
            ..sort((a, b) {
              if (a.time == null && b.time == null) return 0;
              if (a.time == null) return 1;
              if (b.time == null) return -1;
              return (a.time!.hour * 60 + a.time!.minute).compareTo(
                b.time!.hour * 60 + b.time!.minute,
              );
            }),
      orElse: () => [],
    );
  }

  Set<int> daysWithReminders(int year, int month) {
    return state.maybeWhen(
      data: (list) => list
          .where((r) => r.date.year == year && r.date.month == month)
          .map((r) => r.date.day)
          .toSet(),
      orElse: () => {},
    );
  }
}

final remindersProvider =
    StateNotifierProvider<RemindersNotifier, AsyncValue<List<Reminder>>>(
      (ref) => RemindersNotifier(ref),
    );
