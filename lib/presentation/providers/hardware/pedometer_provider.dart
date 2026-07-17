import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

class PedometerNotifier extends StateNotifier<AsyncValue<int>> {
  PedometerNotifier() : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    final status = await Permission.activityRecognition.request();
    if (status.isGranted) {
      Pedometer.stepCountStream.listen(
        (StepCount event) {
          if (mounted) state = AsyncValue.data(event.steps);
        },
        onError: (error) {
          if (mounted) state = AsyncValue.error(error, StackTrace.current);
        },
      );
    } else {
      if (mounted) {
        state = AsyncValue.error(
          'Permiso de actividad física denegado',
          StackTrace.current,
        );
      }
    }
  }
}

final pedometerProvider =
    StateNotifierProvider<PedometerNotifier, AsyncValue<int>>((ref) {
      return PedometerNotifier();
    });
