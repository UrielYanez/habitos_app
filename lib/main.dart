import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vita_habit/config/config.dart';
import 'package:vita_habit/infrastructure/datasource/secure_local_storage.dart';
import 'package:vita_habit/infrastructure/services/notifications_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar notificaciones
  await NotificationsService.initialize();
  await NotificationsService.requestPermissions();

  await Supabase.initialize(
    url: SupabaseConstants.url,
    publishableKey: SupabaseConstants.publishableKey,
    authOptions: FlutterAuthClientOptions(localStorage: SecureLocalStorage()),
  );

  // Inicializar suscripciones en tiempo real
  NotificationsService.setupRemoteSubscriptions();

  debugPrint('Supabase inicializado: ${Supabase.instance.client.rest.url}');

  // Prueba real de conexión a la base de datos
  try {
    final response = await Supabase.instance.client
        .from('profiles')
        .select()
        .limit(1);
    debugPrint('Conexión a Supabase Exitosa. Respuesta: $response');
  } catch (e) {
    debugPrint('Error de conexión a Supabase: $e');
  }

  runApp(const ProviderScope(child: HabitosApp()));
}

class HabitosApp extends ConsumerWidget {
  const HabitosApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme().getTheme(),
      routerConfig: router,
    );
  }
}
