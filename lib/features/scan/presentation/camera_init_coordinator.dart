import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../domain/camera_service.dart';

abstract final class CameraInitCoordinator {
  static Future<void>? _activeOp;
  static int _globalGen = 0;
  static Timer? _watchdogTimer;
  static int _stallCount = 0;

  static int get currentGeneration => _globalGen;

  @visibleForTesting
  static void resetForTesting() {
    stopWatchdog();
    _activeOp = null;
    _globalGen = 0;
  }

  static Future<bool> initialize({
    required CameraService camera,
    required CameraLens lens,
    Future<void> Function()? onScannerInit,
    required bool Function() isMounted,
  }) async {
    final gen = ++_globalGen;
    if (kDebugMode) debugPrint('[scan] [1] camera initialize start gen=$gen');
    final prev = _activeOp;
    final c = Completer<void>();
    _activeOp = c.future;
    try {
      if (prev != null) {
        try { await prev; } catch (_) {}
      }
      if (!isMounted() || gen != _globalGen) return false;

      await camera.initialize(lens: lens);
      if (!isMounted() || gen != _globalGen) {
        await camera.dispose();
        return false;
      }

      if (onScannerInit != null) {
        try { await onScannerInit(); } catch (_) {}
      }
      if (!isMounted() || gen != _globalGen) {
        await camera.dispose();
        return false;
      }

      if (kDebugMode) debugPrint('[scan] [2] camera initialize finish gen=$gen');
      return true;
    } catch (e, st) {
      if (kDebugMode) debugPrint('[scan] camera init error gen=$gen: $e\n$st');
      rethrow;
    } finally {
      if (_activeOp == c.future) _activeOp = null;
      c.complete();
    }
  }

  static Future<void> dispose({required CameraService camera}) async {
    stopWatchdog();
    final gen = ++_globalGen;
    if (kDebugMode) debugPrint('[scan] [3] camera dispose gen=$gen');
    final prev = _activeOp;
    final c = Completer<void>();
    _activeOp = c.future;
    try {
      if (prev != null) {
        try { await prev; } catch (_) {}
      }
      try { await camera.stopImageStream(); } catch (_) {}
      await camera.dispose();
    } catch (e, st) {
      if (kDebugMode) debugPrint('[scan] camera dispose error gen=$gen: $e\n$st');
    } finally {
      if (_activeOp == c.future) _activeOp = null;
      c.complete();
    }
  }

  static void handleLifecycle({
    required AppLifecycleState state,
    required CameraService camera,
    required Future<void> Function() onReinit,
    required VoidCallback onStartWatchdog,
  }) {
    if (kDebugMode) debugPrint('[scan] lifecycle state: $state');
    if (state == AppLifecycleState.inactive) return;
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      stopWatchdog();
      dispose(camera: camera);
    } else if (state == AppLifecycleState.resumed) {
      final last = camera.lastFrameTime;
      if (!camera.isInitialized || (last != null && DateTime.now().difference(last) > const Duration(seconds: 2))) {
        if (kDebugMode) debugPrint('[scan] resumed: re-initializing camera');
        onReinit();
      }
      onStartWatchdog();
    }
  }

  static void startWatchdog({
    required CameraService camera,
    required Future<void> Function() onReinit,
    required VoidCallback onStallExceeded,
    required bool Function() isEligible,
    bool resetStall = false,
  }) {
    if (resetStall) _stallCount = 0;
    _watchdogTimer?.cancel();
    _watchdogTimer = Timer.periodic(const Duration(milliseconds: 500), (_) async {
      if (!isEligible()) return;
      final last = camera.lastFrameTime;
      final isStalled = !camera.isInitialized ||
          (last != null && DateTime.now().difference(last) > const Duration(seconds: 2));
      if (isStalled) {
        if (_stallCount == 0) {
          _stallCount++;
          if (kDebugMode) debugPrint('[scan] watchdog: stream stalled for 2s, triggering re-init');
          await onReinit();
        } else {
          if (kDebugMode) debugPrint('[scan] watchdog: second stall, showing retry view');
          stopWatchdog();
          onStallExceeded();
        }
      } else {
        _stallCount = 0;
      }
    });
  }

  static void stopWatchdog() {
    _watchdogTimer?.cancel();
    _watchdogTimer = null;
    _stallCount = 0;
  }
}
