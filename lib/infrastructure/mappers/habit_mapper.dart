import 'package:vita_habit/domain/entities/habit.dart';
import 'package:vita_habit/infrastructure/models/habit_model.dart';
import 'package:vita_habit/infrastructure/utils/sanitizer.dart';

class HabitMapper {
  // ── Desde modelo local (en memoria) ──────────────────────────────────────
  static Habit fromModel(HabitModel model) => Habit(
        id: model.id,
        name: model.name,
        category: _parseCategory(model.category),
        goalValue: model.goalValue,
        unit: _parseUnit(model.unit),
        currentValue: model.currentValue,
        isActive: model.isActive,
        streakDays: model.streakDays,
        scheduledTime: model.scheduledTime != null
            ? DateTime.tryParse(model.scheduledTime!)
            : null,
      );

  static HabitModel toModel(Habit entity) => HabitModel(
        id: entity.id,
        name: entity.name,
        category: entity.category.name,
        goalValue: entity.goalValue,
        unit: entity.unit.name,
        currentValue: entity.currentValue,
        isActive: entity.isActive,
        streakDays: entity.streakDays,
        scheduledTime: entity.scheduledTime?.toIso8601String(),
      );

  // ── Desde/hacia Supabase (snake_case) ────────────────────────────────────
  static Habit fromSupabase(Map<String, dynamic> json) {
    // Si last_reset_date es de ayer o antes, el progreso del día es 0
    double currentValue = (json['current_value'] as num? ?? 0).toDouble();
    final lastResetStr = json['last_reset_date'] as String?;
    if (lastResetStr != null) {
      final lastReset = DateTime.tryParse(lastResetStr);
      final today = DateTime.now();
      if (lastReset != null &&
          (lastReset.year != today.year ||
           lastReset.month != today.month ||
           lastReset.day != today.day)) {
        currentValue = 0; // Reset visual (el UPDATE lo hace el datasource)
      }
    }

    return Habit(
      id: json['id'] as String,
      name: json['name'] as String,
      category: _parseCategory(json['category'] as String),
      goalValue: (json['goal_value'] as num).toDouble(),
      unit: _parseUnit(json['unit'] as String),
      currentValue: currentValue,
      isActive: json['is_active'] as bool? ?? false,
      streakDays: json['streak_days'] as int? ?? 0,
      scheduledTime: json['scheduled_time'] != null
          ? DateTime.tryParse(json['scheduled_time'] as String)
          : null,
    );
  }

  static Map<String, dynamic> toSupabase(Habit entity, String userId) => {
        'user_id': userId,
        'name': Sanitizer.escapeHtml(entity.name),
        'category': entity.category.name,
        'goal_value': entity.goalValue,
        'unit': entity.unit.name,
        'current_value': entity.currentValue,
        'is_active': entity.isActive,
        'streak_days': entity.streakDays,
        'scheduled_time': entity.scheduledTime?.toIso8601String(),
        'last_reset_date': _todayStr(),
      };

  static String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  // ── Helpers privados ─────────────────────────────────────────────────────
  static HabitCategory _parseCategory(String raw) =>
      HabitCategory.values.firstWhere(
        (c) => c.name == raw,
        orElse: () => HabitCategory.physical,
      );

  static HabitUnit _parseUnit(String raw) =>
      HabitUnit.values.firstWhere(
        (u) => u.name == raw,
        orElse: () => HabitUnit.minutes,
      );
}
