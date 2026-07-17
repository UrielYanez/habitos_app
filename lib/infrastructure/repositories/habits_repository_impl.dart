import 'package:vita_habit/domain/datasources/habits_datasource.dart';
import 'package:vita_habit/domain/entities/habit.dart';
import 'package:vita_habit/domain/repositories/habits_repository.dart';

class HabitsRepositoryImpl implements HabitsRepository {
  final HabitsDatasource datasource;

  const HabitsRepositoryImpl(this.datasource);

  @override
  Future<List<Habit>> getTodayHabits() => datasource.getTodayHabits();

  @override
  Future<List<Habit>> getAllHabits() => datasource.getAllHabits();

  @override
  Future<Habit> updateProgress(String habitId, double newValue) =>
      datasource.updateProgress(habitId, newValue);

  @override
  Future<Habit> toggleActive(String habitId) =>
      datasource.toggleActive(habitId);

  @override
  Future<void> saveHabit(Habit habit) => datasource.saveHabit(habit);

  @override
  Future<void> deleteHabit(String habitId) => datasource.deleteHabit(habitId);
}
