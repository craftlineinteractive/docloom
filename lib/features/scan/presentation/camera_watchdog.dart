import 'dart:async';
import 'package:flutter/foundation.dart';
import '../domain/camera_service.dart';

enum CameraWatchdogState { initializing, running, failed }

class CameraWatchdog {
  Timer? _timer;
  int _stallCount = 0;
  CameraWatchdogState _state = CameraWatchdogState.initializing;
  DateTime? _initStart;

  CameraWatchdogState get state => _state;
  int get stallCount => _stallCount;

  void start({
    required CameraService camera,
    required Future<void> Function() onReinit,
    required VoidCallback onStallExceeded,
    required bool Function() isEligible,
    bool resetStall = false,
  }) {
    if (resetStall) _stallCount = 0;
    _state = CameraWatchdogState.initializing;
    _initStart = DateTime.now();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) async {
      if (!isEligible()) return;
      final now = DateTime.now();
      if (_state == CameraWatchdogState.initializing) {
        if (camera.isInitialized && camera.lastFrameTime != null) {
          _state = CameraWatchdogState.running;
          _stallCount = 0;
          return;
        }
        if (_initStart != null && now.difference(_initStart!) > const Duration(seconds: 10)) {
          if (kDebugMode) debugPrint('[cam] watchdog: 10s init timeout exceeded');
          _state = CameraWatchdogState.failed;
          stop();
          onStallExceeded();
        }
        return;
      }
      if (_state == CameraWatchdogState.running) {
        final last = camera.lastFrameTime;
        final isStalled = !camera.isInitialized ||
            (last != null && now.difference(last) > const Duration(seconds: 2));
        if (isStalled) {
          if (kDebugMode) debugPrint('[cam] watchdog stall: isInit=${camera.isInitialized}, last=$last, stall=$_stallCount');
          if (_stallCount == 0) {
            _stallCount++;
            _state = CameraWatchdogState.initializing;
            _initStart = now;
            if (kDebugMode) debugPrint('[cam] watchdog: stream stalled for 2s, triggering re-init');
            await onReinit();
          } else {
            if (kDebugMode) debugPrint('[cam] watchdog: stall exceeded, showing retry view');
            _state = CameraWatchdogState.failed;
            stop();
            onStallExceeded();
          }
        } else {
          _stallCount = 0;
        }
      }
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _stallCount = 0;
    _state = CameraWatchdogState.initializing;
    _initStart = null;
  }
}
