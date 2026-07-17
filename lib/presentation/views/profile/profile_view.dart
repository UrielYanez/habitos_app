import 'package:flutter/material.dart';
import 'package:vita_habit/config/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vita_habit/presentation/providers/providers.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).maybeWhen(
      data: (p) => p,
      orElse: () => null,
    );
    final name   = profile?.name ?? 'Usuario';
    final height = profile?.heightCm.toStringAsFixed(0) ?? '—';
    final weight = profile?.weightKg.toStringAsFixed(0) ?? '—';
    final age    = profile?.ageYears.toString() ?? '—';
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          CircleAvatar(
            radius: 48,
            backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
            child: const Text(
              'JW',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(name, style: textTheme.headlineMedium),
          Text('Miembro de HabitFlow', style: textTheme.bodyMedium),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MetricChip(label: '$height cm'),
              _MetricChip(label: '$weight kg'),
              _MetricChip(label: '$age años'),
            ],
          ),
          const SizedBox(height: 24),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
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
                Text("This Week's Progress", style: textTheme.titleLarge),
                const SizedBox(height: 12),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatChip(emoji: '🦶', value: '—', label: 'pasos'),
                    _StatChip(emoji: '🔥', value: '—', label: 'cal'),
                    _StatChip(emoji: '📍', value: '—', label: 'km'),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Conecta tu wearable para ver el progreso semanal',
                  style: textTheme.bodyMedium, 
                  textAlign: TextAlign.center
                ),
              ],
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  const _MetricChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.primary,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;

  const _StatChip({
    required this.emoji,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppTheme.textPrimary,
          ),
        ),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
