import 'dart:async';
import 'package:flutter/foundation.dart';
import '../domain/camera_service.dart';

abstract final class CameraInitCoordinator {
  static Future<void>? _activeOp;
  static int _globalGen = 0;

  static int get currentGeneration => _globalGen;

  @visibleForTesting
  static void resetForTesting() {
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
      c.complete();
    }
  }

  static Future<void> dispose({required CameraService camera}) async {
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
      c.complete();
    }
  }
}
