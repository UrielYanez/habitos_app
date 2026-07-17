import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vita_habit/config/config.dart';
import 'package:vita_habit/presentation/providers/providers.dart';
import 'package:vita_habit/presentation/widgets/widgets.dart';


class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(habitsProvider);
    final pending = ref.watch(pendingHabitsProvider);
    final completed = ref.watch(completedHabitsProvider);
    final streak = ref.watch(activeStreakProvider);
    final nextHabit = ref.watch(nextHabitProvider);
    final textTheme = Theme.of(context).textTheme;
    final profile = ref.watch(profileProvider).maybeWhen(
      data: (p) => p,
      orElse: () => null,
    );

    return RefreshIndicator(
      onRefresh: () async => ref.read(habitsProvider.notifier).loadHabits(),
      child: CustomScrollView(
        slivers: [
          // ── AppBar ────────────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            pinned: false,
            backgroundColor: AppTheme.surface,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.zero,
              title: _HomeAppBar(),
            ),
            toolbarHeight: 64,
          ),

          // ── Selector de fecha ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: _DateSelector(
              selectedDate: _selectedDate,
              onDateSelected: (d) => setState(() => _selectedDate = d),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 16),

                // ── Banner de racha ─────────────────────────────────────
                StreakBanner(
                  streakDays: streak,
                  pendingCount: pending.length,
                  completedCount: completed.length,
                  totalCount: pending.length + completed.length,
                  nextHabitName: nextHabit?.name,
                  nextHabitTime: nextHabit?.scheduledTime,
                ),

                const SizedBox(height: 24),

                // ── Encabezado "Tus Actividades" ────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tus Actividades', style: textTheme.titleLarge),
                    TextButton(
                      onPressed: () => context.go(
                        '${AppConstants.homeRoute}/statistics',
                      ),
                      child: const Text('Ver todo'),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // ── Lista de actividades del día ─────────────────────────
                habitsAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (e, _) => Center(
                    child: Text(
                      'Error al cargar hábitos',
                      style: textTheme.bodyLarge,
                    ),
                  ),
                  data: (habits) => Column(
                    children: habits
                        .take(5)
                        .map(
                            (h) => ActivityCard(
                              habit: h,
                              onToggle: () => ref
                                  .read(habitsProvider.notifier)
                                  .toggleActive(h.id),
                              onTap: () => showModalBottomSheet( // ← AGREGAR
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => EditHabitSheet(habit: h),
                              ),
                            ),
                          )
                        .toList(),
                  ),
                ),

                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── AppBar personalizado ─────────────────────────────────────────────────────
class _HomeAppBar extends ConsumerWidget { // ← cambiar StatelessWidget por ConsumerWidget
  @override
  Widget build(BuildContext context, WidgetRef ref) { // ← agregar WidgetRef ref
    final name = ref.watch(profileProvider).maybeWhen(
      data: (p) => p?.name ?? 'Usuario',
      orElse: () => 'Usuario',
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppTheme.primary.withValues(alpha: 0.2),
            child: const Text(
              'JW',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppConstants.appName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
                Text(
                  'Hola, $name',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.settings_outlined,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Selector horizontal de fecha ─────────────────────────────────────────────
class _DateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const _DateSelector({
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(
      31,
      (i) => DateTime(now.year, now.month, i + 1),
    );

    return SizedBox(
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected =
              day.day == selectedDate.day && day.month == selectedDate.month;
          final isToday =
              day.day == now.day && day.month == now.month;

          return GestureDetector(
            onTap: () => onDateSelected(day),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary
                    : isToday
                        ? AppTheme.primary.withValues(alpha: 0.12)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _dayLetter(day.weekday),
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected
                          ? Colors.white
                          : AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : isToday
                              ? AppTheme.primary
                              : AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _dayLetter(int weekday) {
    const letters = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    return letters[weekday - 1];
  }
}
