import 'package:flutter/material.dart';
import 'package:vita_habit/config/theme/app_theme.dart';

class StreakBanner extends StatelessWidget {
  final int streakDays;
  final int pendingCount;
  final int completedCount;
  final int totalCount;
  final String? nextHabitName;
  final DateTime? nextHabitTime;

  const StreakBanner({
    super.key,
    required this.streakDays,
    required this.pendingCount,
    required this.completedCount,
    required this.totalCount,
    this.nextHabitName,
    this.nextHabitTime,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado con llama y racha
          Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tu Progreso',
                    style: textTheme.labelSmall?.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Racha de $streakDays días',
                    style: textTheme.titleMedium?.copyWith(
                      color: AppTheme.streak,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          _ProgressRow(
            label: 'Actividades pendientes',
            value: totalCount > 0 ? pendingCount / totalCount : 0,
            color: AppTheme.pending,
            count: pendingCount,
            total: totalCount,
          ),

          const SizedBox(height: 8),

          _ProgressRow(
            label: 'Actividades completadas',
            value: totalCount > 0 ? completedCount / totalCount : 0,
            color: AppTheme.completed,
            count: completedCount,
            total: totalCount,
          ),

          // Siguiente actividad
          if (nextHabitName != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppTheme.divider),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Siguiente Actividad',
                      style: textTheme.labelSmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      nextHabitName!,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (nextHabitTime != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: AppTheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(nextHabitTime!),
                          style: textTheme.titleMedium?.copyWith(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final hour12 = h % 12 == 0 ? 12 : h % 12;
    return '$hour12:$m $period';
  }
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final int count;
  final int total;

  const _ProgressRow({
    required this.label,
    required this.value,
    required this.color,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: value,
                  backgroundColor: color.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: AppTheme.textSecondary,
        ),
      ],
    );
  }
}
