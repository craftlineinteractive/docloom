import 'package:camera/camera.dart';
import '../domain/camera_service.dart';

abstract final class PluginCameraMappers {
  static ResolutionPreset mapResolutionPreset(CameraPreset preset) => switch (preset) {
        CameraPreset.low => ResolutionPreset.low,
        CameraPreset.medium => ResolutionPreset.medium,
        CameraPreset.high => ResolutionPreset.high,
        CameraPreset.veryHigh => ResolutionPreset.veryHigh,
        CameraPreset.ultraHigh => ResolutionPreset.ultraHigh,
        CameraPreset.max => ResolutionPreset.max,
      };

  static FlashMode mapFlashMode(CameraFlash flash, {bool isTorch = false}) {
    if (isTorch && flash == CameraFlash.on) {
      return FlashMode.torch;
    }
    return switch (flash) {
      CameraFlash.off => FlashMode.off,
      CameraFlash.on => FlashMode.always,
      CameraFlash.auto => FlashMode.auto,
    };
  }

  static CameraLens? mapLensDirection(CameraLensDirection dir) => switch (dir) {
        CameraLensDirection.back => CameraLens.back,
        CameraLensDirection.front => CameraLens.front,
        CameraLensDirection.external => CameraLens.external,
      };

  static CameraLensDirection mapToCameraLensDirection(CameraLens lens) => switch (lens) {
        CameraLens.back => CameraLensDirection.back,
        CameraLens.front => CameraLensDirection.front,
        CameraLens.external => CameraLensDirection.external,
      };
}
