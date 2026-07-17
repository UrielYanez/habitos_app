import 'package:flutter/material.dart';
import 'package:vita_habit/config/theme/app_theme.dart';
import 'package:vita_habit/presentation/views/habits/habits_view.dart';
import 'package:vita_habit/presentation/widgets/shared/bottom_nav_bar.dart';
import 'package:vita_habit/presentation/widgets/habits/add_habit_sheet.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  void _openAddHabit(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddHabitSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Hábitos'),
        backgroundColor: AppTheme.surface,
        elevation: 0,
      ),
      body: const HabitsView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _openAddHabit(context);
        },
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        tooltip: 'Agregar hábito',
        child: const Icon(Icons.add_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }
}
