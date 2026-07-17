import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vita_habit/config/constants/app_constants.dart';
import 'package:vita_habit/presentation/screens/screens.dart';
import 'package:vita_habit/presentation/providers/providers.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  // Escuchar el estado de autenticación para reconstruir el router si cambia
  ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: AppConstants.splashRoute,
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isAuth = session != null;
      final isSplash = state.matchedLocation == AppConstants.splashRoute;
      final isLoggingIn = state.matchedLocation == AppConstants.authRoute;

      if (isSplash) return null; // Splash maneja su propio retardo

      if (!isAuth && !isLoggingIn) return AppConstants.authRoute;
      if (isAuth && isLoggingIn) return AppConstants.homeRoute;

      return null;
    },
    routes: [
      GoRoute(
        path: AppConstants.splashRoute,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppConstants.authRoute,
        builder: (context, state) => const AuthScreen(),
      ),
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
});
