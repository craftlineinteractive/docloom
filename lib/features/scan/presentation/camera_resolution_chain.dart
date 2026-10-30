import 'package:flutter/foundation.dart';
import '../domain/camera_service.dart';

abstract final class CameraResolutionChain {
  static CameraPreset? sessionPreset;
  static const chain = [
    CameraPreset.max,
    CameraPreset.ultraHigh,
    CameraPreset.veryHigh,
    CameraPreset.high,
  ];

  static Future<bool> initialize(CameraService camera, CameraLens lens) async {
    final start = sessionPreset ?? CameraPreset.max;
    final candidates = [
      start,
      ...chain.where((p) => p.index < start.index).toList().reversed,
    ].toSet().toList();

    Object? lastErr;
    for (final preset in candidates) {
      try {
        if (kDebugMode) debugPrint('[cam] resolution chain trying preset: $preset');
        await camera.initialize(preset: preset, lens: lens);
        if (camera.isInitialized) {
          sessionPreset = preset;
          if (kDebugMode) debugPrint('[cam] resolution chain selected & locked preset: $preset');
          return true;
        }
      } catch (e) {
        lastErr = e;
        if (kDebugMode) debugPrint('[cam] resolution preset $preset failed: $e');
      }
    }
    if (kDebugMode && lastErr != null) debugPrint('[cam] all resolution chain presets failed: $lastErr');
    return false;
  }
}
