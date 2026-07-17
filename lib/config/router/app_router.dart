import 'package:go_router/go_router.dart';
import 'package:vita_habit/config/constants/app_constants.dart';
import 'package:vita_habit/presentation/screens/screens.dart';

final appRouter = GoRouter(
  initialLocation: AppConstants.splashRoute,
  routes: [
    // ── Splash ──────────────────────────────────────────────────────────
    GoRoute(
      path: AppConstants.splashRoute,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppConstants.authRoute,
      builder: (context, state) => const AuthScreen(),
    ),
    // ── Contenedor principal con bottom nav ─────────────────────────────
    GoRoute(
      path: AppConstants.homeRoute,
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'statistics',
          builder: (context, state) => const ActivityStatisticsScreen(),
        ),
      ],
    ),

    GoRoute(
      path: AppConstants.habitsRoute,
      builder: (context, state) => const HabitsScreen(),
    ),

    GoRoute(
      path: AppConstants.calendarRoute,
      builder: (context, state) => const CalendarScreen(),
    ),

    GoRoute(
      path: AppConstants.profileRoute,
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);
