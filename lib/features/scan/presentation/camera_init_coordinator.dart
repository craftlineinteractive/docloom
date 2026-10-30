import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_better_scanner/flutter_better_scanner.dart' show ScannerController;
import '../data/plugin_camera_service.dart';
import '../domain/camera_service.dart';
import 'camera_resolution_chain.dart';
import 'camera_watchdog.dart';

abstract final class CameraInitCoordinator {
  static Future<void>? _activeOp;
  static int _globalGen = 0;
  static final _watchdog = CameraWatchdog();

  static int get currentGeneration => _globalGen;
  static CameraWatchdog get watchdog => _watchdog;

  @visibleForTesting
  static void resetForTesting() {
    stopWatchdog();
    _activeOp = null;
    _globalGen = 0;
    CameraResolutionChain.sessionPreset = null;
  }

  static Future<bool> initialize({
    required CameraService camera,
    required CameraLens lens,
    Future<void> Function()? onScannerInit,
    required bool Function() isMounted,
    ScannerController? scannerController,
  }) async {
    final gen = ++_globalGen;
    if (kDebugMode) debugPrint('[cam] [1] camera initialize start gen=$gen');
    final prev = _activeOp; final c = Completer<void>(); _activeOp = c.future;
    try {
      if (prev != null) { try { await prev; } catch (_) {} }
      if (!isMounted() || gen != _globalGen) return false;

      try { await camera.stopImageStream(); } catch (_) {}
      await camera.dispose();
      if (!isMounted() || gen != _globalGen) return false;

      bool ok = false;
      if (onScannerInit != null) {
        try {
          await onScannerInit();
          if (scannerController != null && scannerController.cameraController != null && scannerController.isReady) {
            if (camera is PluginCameraService) camera.attachTo(scannerController.cameraController);
            ok = true;
          }
        } catch (e) {
          if (kDebugMode) debugPrint('[cam] onScannerInit failed: $e');
        }
      }

      if (!ok) {
        if (kDebugMode) debugPrint('[cam] using direct CameraResolutionChain fallback');
        ok = await CameraResolutionChain.initialize(camera, lens);
      }

      if (!isMounted() || gen != _globalGen) { await camera.dispose(); return false; }
      if (kDebugMode) debugPrint('[cam] [2] camera initialize finish gen=$gen, ok=$ok, isInit=${camera.isInitialized}');
      return ok;
    } catch (e, st) {
      if (kDebugMode) debugPrint('[cam] camera init error gen=$gen: $e\n$st');
      rethrow;
    } finally {
      if (_activeOp == c.future) _activeOp = null;
      c.complete();
    }
  }

  static Future<void> dispose({required CameraService camera, ScannerController? scannerController}) async {
    stopWatchdog();
    final gen = ++_globalGen;
    if (kDebugMode) debugPrint('[cam] [3] camera dispose gen=$gen');
    final prev = _activeOp; final c = Completer<void>(); _activeOp = c.future;
    try {
      if (prev != null) { try { await prev; } catch (_) {} }
      try { await camera.stopImageStream(); } catch (_) {}
      await camera.dispose();
      if (scannerController != null) {
        try { await scannerController.suspend(); } catch (_) {}
        try { scannerController.dispose(); } catch (_) {}
      }
    } catch (e, st) {
      if (kDebugMode) debugPrint('[cam] camera dispose error gen=$gen: $e\n$st');
    } finally {
      if (_activeOp == c.future) _activeOp = null;
      c.complete();
    }
  }

  static void handleLifecycle({
    required AppLifecycleState state, required CameraService camera,
    required Future<void> Function() onReinit, required VoidCallback onStartWatchdog,
    ScannerController? scannerController,
  }) {
    if (kDebugMode) debugPrint('[cam] lifecycle state: $state');
    if (state == AppLifecycleState.inactive) return;
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      stopWatchdog(); dispose(camera: camera, scannerController: scannerController);
    } else if (state == AppLifecycleState.resumed) {
      final last = camera.lastFrameTime;
      if (!camera.isInitialized || (last != null && DateTime.now().difference(last) > const Duration(seconds: 2))) {
        if (kDebugMode) debugPrint('[cam] resumed: re-initializing camera');
        onReinit();
      }
      onStartWatchdog();
    }
  }

  static void startWatchdog({
    required CameraService camera, required Future<void> Function() onReinit,
    required VoidCallback onStallExceeded, required bool Function() isEligible,
    bool resetStall = false,
  }) {
    _watchdog.start(
      camera: camera, onReinit: onReinit, onStallExceeded: onStallExceeded,
      isEligible: isEligible, resetStall: resetStall,
    );
  }

  static void stopWatchdog() => _watchdog.stop();
}
