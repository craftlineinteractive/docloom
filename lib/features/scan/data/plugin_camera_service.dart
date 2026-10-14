import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import '../domain/camera_service.dart';

class PluginCameraService implements CameraService {
  PluginCameraService();

  CameraController? _controller;
  List<CameraDescription> _cameras = const [];
  CameraLens _currentLens = CameraLens.back;
  CameraFlash _currentFlash = CameraFlash.off;

  @override
  bool get isInitialized => _controller?.value.isInitialized ?? false;

  @override
  CameraLens get currentLens => _currentLens;

  @override
  CameraFlash get currentFlash => _currentFlash;

  @override
  List<CameraLens> get availableLenses {
    final lenses = <CameraLens>{};
    for (final cam in _cameras) {
      final lens = _mapLensDirection(cam.lensDirection);
      if (lens != null) lenses.add(lens);
    }
    return lenses.toList();
  }

  @override
  Future<void> initialize({
    CameraPreset preset = CameraPreset.high,
    CameraLens lens = CameraLens.back,
  }) async {
    await dispose();
    _cameras = await availableCameras();
    if (_cameras.isEmpty) {
      throw CameraException('no_cameras', 'No cameras available on this device');
    }

    final targetDirection = _mapToCameraLensDirection(lens);
    final selectedCam = _cameras.firstWhere(
      (cam) => cam.lensDirection == targetDirection,
      orElse: () => _cameras.first,
    );
    _currentLens =
        _mapLensDirection(selectedCam.lensDirection) ?? CameraLens.back;

    final controller = CameraController(
      selectedCam,
      _mapResolutionPreset(preset),
      enableAudio: false,
    );
    await controller.initialize();
    _controller = controller;
    await setFlash(_currentFlash);
  }

  @override
  Future<void> dispose() async {
    final controller = _controller;
    _controller = null;
    if (controller != null) {
      await controller.dispose();
    }
  }

  @override
  Future<void> setFlash(CameraFlash flash) async {
    _currentFlash = flash;
    final controller = _controller;
    if (controller != null && controller.value.isInitialized) {
      await controller.setFlashMode(_mapFlashMode(flash));
    }
  }

  @override
  Future<void> setFocusPoint(Offset point) async {
    final controller = _controller;
    if (controller != null && controller.value.isInitialized) {
      final clamped = Offset(
        point.dx.clamp(0.0, 1.0),
        point.dy.clamp(0.0, 1.0),
      );
      await controller.setFocusPoint(clamped);
    }
  }

  @override
  Future<String> takePicture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      throw StateError('Camera is not initialized');
    }
    final file = await controller.takePicture();
    return file.path;
  }

  @override
  Widget previewWidget() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.shrink();
    }
    return CameraPreview(controller);
  }

  ResolutionPreset _mapResolutionPreset(CameraPreset preset) {
    return switch (preset) {
      CameraPreset.low => ResolutionPreset.low,
      CameraPreset.medium => ResolutionPreset.medium,
      CameraPreset.high => ResolutionPreset.high,
      CameraPreset.veryHigh => ResolutionPreset.veryHigh,
      CameraPreset.ultraHigh => ResolutionPreset.ultraHigh,
      CameraPreset.max => ResolutionPreset.max,
    };
  }

  FlashMode _mapFlashMode(CameraFlash flash) {
    return switch (flash) {
      CameraFlash.off => FlashMode.off,
      CameraFlash.on => FlashMode.always,
      CameraFlash.auto => FlashMode.auto,
    };
  }

  CameraLens? _mapLensDirection(CameraLensDirection dir) {
    return switch (dir) {
      CameraLensDirection.back => CameraLens.back,
      CameraLensDirection.front => CameraLens.front,
      CameraLensDirection.external => CameraLens.external,
    };
  }

  CameraLensDirection _mapToCameraLensDirection(CameraLens lens) {
    return switch (lens) {
      CameraLens.back => CameraLensDirection.back,
      CameraLens.front => CameraLensDirection.front,
      CameraLens.external => CameraLensDirection.external,
    };
  }
}
