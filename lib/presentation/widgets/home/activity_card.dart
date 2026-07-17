import 'package:flutter/material.dart';
import 'package:vita_habit/config/theme/app_theme.dart';
import 'package:vita_habit/domain/entities/habit.dart';

class ActivityCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onToggle;
  final VoidCallback? onTap; // ← AGREGAR

  const ActivityCard({
    super.key,
    required this.habit,
    required this.onToggle,
    this.onTap, // ← AGREGAR
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _categoryColor(habit.category).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _categoryIcon(habit.category),
                color: _categoryColor(habit.category),
                size: 22,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (habit.scheduledTime != null)
                    Text(
                      _formatTime(habit.scheduledTime!),
                      style: textTheme.labelSmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  Text(
                    habit.name,
                    style: textTheme.titleMedium?.copyWith(
                      decoration: habit.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: habit.isCompleted
                          ? AppTheme.textSecondary
                          : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    habit.currentLabel,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: habit.progress,
                      backgroundColor: AppTheme.divider,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        habit.isCompleted
                            ? AppTheme.completed
                            : AppTheme.primary,
                      ),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            GestureDetector(
              onTap: onToggle,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: habit.isCompleted
                      ? AppTheme.completed.withValues(alpha: 0.15)
                      : AppTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  habit.isCompleted
                      ? Icons.check_rounded
                      : habit.isActive
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: habit.isCompleted ? AppTheme.completed : Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(HabitCategory cat) {
    return switch (cat) {
      HabitCategory.cognitive => Icons.menu_book_rounded,
      HabitCategory.physical => Icons.directions_run_rounded,
      HabitCategory.hydration => Icons.water_drop_rounded,
      HabitCategory.productivity => Icons.school_rounded,
      HabitCategory.rest => Icons.bedtime_rounded,
    };
  }

  Color _categoryColor(HabitCategory cat) {
    return switch (cat) {
      HabitCategory.cognitive => const Color(0xFF6C5CE7),
      HabitCategory.physical => const Color(0xFF00B894),
      HabitCategory.hydration => const Color(0xFF0984E3),
      HabitCategory.productivity => const Color(0xFFE17055),
      HabitCategory.rest => const Color(0xFF6C5CE7),
    };
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final hour12 = h % 12 == 0 ? 12 : h % 12;
    return 'Hoy, $hour12:$m $period';
  }
}
