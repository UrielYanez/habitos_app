enum HabitCategory { cognitive, physical, hydration, productivity, rest }

enum HabitUnit { minutes, km, liters, steps, times }

class Habit {
  final String id;
  final String name;
  final HabitCategory category;
  final double goalValue;
  final HabitUnit unit;
  final double currentValue;
  final bool isActive;
  final int streakDays;
  final DateTime? scheduledTime;

  const Habit({
    required this.id,
    required this.name,
    required this.category,
    required this.goalValue,
    required this.unit,
    this.currentValue = 0,
    this.isActive = false,
    this.streakDays = 0,
    this.scheduledTime,
  });

  /// Progreso de 0.0 a 1.0
  double get progress =>
      goalValue > 0 ? (currentValue / goalValue).clamp(0.0, 1.0) : 0.0;

  bool get isCompleted => currentValue >= goalValue;

  String get goalLabel {
    switch (unit) {
      case HabitUnit.minutes:
        return '${goalValue.toInt()} min';
      case HabitUnit.km:
        return '${goalValue.toInt()} km';
      case HabitUnit.liters:
        return '${goalValue.toStringAsFixed(0)} Litros';
      case HabitUnit.steps:
        return '${goalValue.toInt()} pasos';
      case HabitUnit.times:
        return '${goalValue.toInt()} veces';
    }
  }

  String get currentLabel {
    switch (unit) {
      case HabitUnit.minutes:
        return '${currentValue.toInt()}/${goalValue.toInt()} min';
      case HabitUnit.km:
        return '${currentValue.toStringAsFixed(2)}/${goalValue.toInt()} km';
      case HabitUnit.liters:
        return '${currentValue.toStringAsFixed(1)}/${goalValue.toStringAsFixed(0)} L';
      case HabitUnit.steps:
        return '${currentValue.toInt()}/${goalValue.toInt()} pasos';
      case HabitUnit.times:
        return '${currentValue.toInt()}/${goalValue.toInt()} veces';
    }
  }

  Habit copyWith({
    String? id,
    String? name,
    HabitCategory? category,
    double? goalValue,
    HabitUnit? unit,
    double? currentValue,
    bool? isActive,
    int? streakDays,
    DateTime? scheduledTime,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      goalValue: goalValue ?? this.goalValue,
      unit: unit ?? this.unit,
      currentValue: currentValue ?? this.currentValue,
      isActive: isActive ?? this.isActive,
      streakDays: streakDays ?? this.streakDays,
      scheduledTime: scheduledTime ?? this.scheduledTime,
    );
  }
}
