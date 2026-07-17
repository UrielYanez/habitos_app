import 'package:vita_habit/domain/datasources/habits_datasource.dart';
import 'package:vita_habit/domain/entities/habit.dart';
import 'package:vita_habit/infrastructure/mappers/habit_mapper.dart';
import 'package:vita_habit/infrastructure/models/habit_model.dart';

/// Implementación local en memoria.
/// Cuando se integre persistencia (Hive / SQLite) o una API,
/// solo hay que cambiar esta clase; domain y presentation no se tocan.
class LocalHabitsDatasourceImpl implements HabitsDatasource {
  // ── Datos semilla (basados en el prototipo de Figma) ─────────────────────
  final List<HabitModel> _habits = [
    HabitModel(
      id: '1',
      name: 'Leer',
      category: 'cognitive',
      goalValue: 20,
      unit: 'minutes',
      currentValue: 10,
      isActive: true,
      streakDays: 4,
      scheduledTime: DateTime.now()
          .copyWith(hour: 8, minute: 10)
          .toIso8601String(),
    ),
    HabitModel(
      id: '2',
      name: 'Ciclismo',
      category: 'physical',
      goalValue: 20,
      unit: 'km',
      currentValue: 20,
      isActive: false,
      streakDays: 4,
      scheduledTime: DateTime.now()
          .copyWith(hour: 6, minute: 30)
          .toIso8601String(),
    ),
    HabitModel(
      id: '3',
      name: 'Tomar agua',
      category: 'hydration',
      goalValue: 2,
      unit: 'liters',
      currentValue: 1.2,
      isActive: false,
      streakDays: 4,
    ),
    HabitModel(
      id: '4',
      name: 'Natación',
      category: 'physical',
      goalValue: 30,
      unit: 'minutes',
      currentValue: 0,
      isActive: false,
      streakDays: 4,
    ),
    HabitModel(
      id: '5',
      name: 'Estudiar',
      category: 'productivity',
      goalValue: 30,
      unit: 'minutes',
      currentValue: 0,
      isActive: false,
      streakDays: 4,
      scheduledTime: DateTime.now()
          .copyWith(hour: 18, minute: 0)
          .toIso8601String(),
    ),
    HabitModel(
      id: '6',
      name: 'Yoga',
      category: 'physical',
      goalValue: 30,
      unit: 'minutes',
      currentValue: 30,
      isActive: false,
      streakDays: 4,
      scheduledTime: DateTime.now()
          .copyWith(hour: 6, minute: 0)
          .toIso8601String(),
    ),
  ];

  @override
  Future<List<Habit>> getTodayHabits() async {
    await Future.delayed(const Duration(milliseconds: 200)); // simula latencia
    return _habits.map(HabitMapper.fromModel).toList();
  }

  @override
  Future<List<Habit>> getAllHabits() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _habits.map(HabitMapper.fromModel).toList();
  }

  @override
  Future<Habit> updateProgress(String habitId, double newValue) async {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index == -1) throw Exception('Hábito no encontrado: $habitId');
    final updated = HabitModel(
      id: _habits[index].id,
      name: _habits[index].name,
      category: _habits[index].category,
      goalValue: _habits[index].goalValue,
      unit: _habits[index].unit,
      currentValue: newValue,
      isActive: _habits[index].isActive,
      streakDays: _habits[index].streakDays,
      scheduledTime: _habits[index].scheduledTime,
    );
    _habits[index] = updated;
    return HabitMapper.fromModel(updated);
  }

  @override
  Future<Habit> toggleActive(String habitId) async {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index == -1) throw Exception('Hábito no encontrado: $habitId');
    final toggled = HabitModel(
      id: _habits[index].id,
      name: _habits[index].name,
      category: _habits[index].category,
      goalValue: _habits[index].goalValue,
      unit: _habits[index].unit,
      currentValue: _habits[index].currentValue,
      isActive: !_habits[index].isActive,
      streakDays: _habits[index].streakDays,
      scheduledTime: _habits[index].scheduledTime,
    );
    _habits[index] = toggled;
    return HabitMapper.fromModel(toggled);
  }

  @override
  Future<void> saveHabit(Habit habit) async {
    final model = HabitMapper.toModel(habit);
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index == -1) {
      _habits.add(model);
    } else {
      _habits[index] = model;
    }
  }

  @override
  Future<void> deleteHabit(String habitId) async {
    _habits.removeWhere((h) => h.id == habitId);
  }
}
