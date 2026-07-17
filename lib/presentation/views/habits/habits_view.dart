import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vita_habit/config/theme/app_theme.dart';
import 'package:vita_habit/presentation/providers/providers.dart';
import 'package:vita_habit/presentation/widgets/widgets.dart';

class HabitsView extends ConsumerWidget {
  const HabitsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);

    return habitsAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (habits) => ListView(
        padding: const EdgeInsets.only(top: 12, bottom: 80),
        children: habits
            .map(
              (h) => HabitListTile(
                habit: h,
                onStart: () =>
                    ref.read(habitsProvider.notifier).toggleActive(h.id),
              ),
            )
            .toList(),
      ),
    );
  }
}
