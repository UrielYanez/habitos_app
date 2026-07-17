import 'package:vita_habit/domain/entities/habit.dart';

abstract class HabitsDatasource {
  Future<List<Habit>> getTodayHabits();
  Future<List<Habit>> getAllHabits();
  Future<Habit> updateProgress(String habitId, double newValue);
  Future<Habit> toggleActive(String habitId);
  Future<void> saveHabit(Habit habit);
  Future<void> deleteHabit(String habitId);
}
