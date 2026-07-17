import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vita_habit/config/config.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  const CustomBottomNavBar({super.key, required this.currentIndex});

  static const _items = [
    (icon: Icons.home_rounded, label: 'Home', route: AppConstants.homeRoute),
    (icon: Icons.repeat_rounded, label: 'Hábitos', route: AppConstants.habitsRoute),
    (icon: Icons.calendar_month_rounded, label: 'Calendario', route: AppConstants.calendarRoute),
    (icon: Icons.person_rounded, label: 'Perfil', route: AppConstants.profileRoute),
  ];

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        context.go(_items[index].route);
      },
      destinations: _items
          .map(
            (item) => NavigationDestination(
              icon: Icon(item.icon),
              label: item.label,
            ),
          )
          .toList(),
    );
  }
}
