import 'package:flutter/material.dart';
import 'package:vita_habit/config/theme/app_theme.dart';
import 'package:vita_habit/presentation/views/calendar/calendar_view.dart';
import 'package:vita_habit/presentation/widgets/shared/bottom_nav_bar.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Calendario'),
        backgroundColor: AppTheme.surface,
        elevation: 0,
      ),
      body: const CalendarView(),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }
}
