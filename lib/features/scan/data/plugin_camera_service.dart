import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../domain/camera_service.dart';
import 'plugin_camera_mappers.dart';

class PluginCameraService implements CameraService {
  PluginCameraService();

  CameraController? _controller;
  List<CameraDescription> _cameras = const [];
  CameraLens _currentLens = CameraLens.back;
  CameraFlash _currentFlash = CameraFlash.off;
  bool _isStreaming = false;

  CameraDescription? _selectedCam;

  @override
  bool get isInitialized => _controller?.value.isInitialized ?? false;

  @override
  CameraLens get currentLens => _currentLens;

  @override
  CameraFlash get currentFlash => _currentFlash;

  @override
  double? get aspectRatio => _controller?.value.aspectRatio;

  @override
  bool get isStreamingImages => _isStreaming;

  @override
  List<CameraLens> get availableLenses {
    final lenses = <CameraLens>{};
    for (final cam in _cameras) {
      final lens = PluginCameraMappers.mapLensDirection(cam.lensDirection);
      if (lens != null) lenses.add(lens);
    }
    return lenses.toList();
  }

  @override
  Future<void> initialize({
    CameraPreset preset = CameraPreset.max,
    CameraLens lens = CameraLens.back,
  }) async {
    await dispose();
    _cameras = await availableCameras();
    if (_cameras.isEmpty) {
      throw CameraException('no_cameras', 'No cameras available on this device');
    }

    final targetDirection = PluginCameraMappers.mapToCameraLensDirection(lens);
    final selectedCam = _cameras.firstWhere(
      (cam) => cam.lensDirection == targetDirection,
      orElse: () => _cameras.first,
    );
    _currentLens = PluginCameraMappers.mapLensDirection(selectedCam.lensDirection) ?? CameraLens.back;
    _selectedCam = selectedCam;

    final controller = CameraController(selectedCam, PluginCameraMappers.mapResolutionPreset(preset), enableAudio: false);
    await controller.initialize();
    _controller = controller;
    try {
      await controller.setFocusMode(FocusMode.auto);
      await controller.setExposureMode(ExposureMode.auto);
    } catch (_) {}
    await setFlash(_currentFlash);
  }

  @override
  Future<void> dispose() async {
    await stopImageStream();
    final controller = _controller;
    _controller = null;
    if (controller != null) await controller.dispose();
  }

  @override
  Future<void> setFlash(CameraFlash flash) async {
    _currentFlash = flash;
    final controller = _controller;
    if (controller != null && controller.value.isInitialized) {
      await controller.setFlashMode(PluginCameraMappers.mapFlashMode(flash));
    }
  }

  Offset? _lastFocusPoint;

  @override
  Future<void> setFocusPoint(Offset point) async {
    _lastFocusPoint = Offset(point.dx.clamp(0.0, 1.0), point.dy.clamp(0.0, 1.0));
    final controller = _controller;
    if (controller != null && controller.value.isInitialized) {
      await controller.setFocusPoint(_lastFocusPoint!);
      try { await controller.setExposurePoint(_lastFocusPoint!); } catch (_) {}
    }
  }

  @override
  Future<String> takePicture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) throw StateError('Camera is not initialized');
    try {
      await controller.setFocusMode(FocusMode.auto);
      await controller.setFocusPoint(_lastFocusPoint ?? const Offset(0.5, 0.5));
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (_) {}
    final file = await controller.takePicture();
    return file.path;
  }

  @override
  Future<void> startImageStream(CameraFrameCallback onFrame) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _isStreaming) return;
    _isStreaming = true; if (kDebugMode) debugPrint('[scan] [4] image stream start');
    await controller.startImageStream((CameraImage image) {
      if (!_isStreaming) return;
      if (image.planes.isNotEmpty) {
        final p = image.planes.first;
        onFrame(p.bytes, image.width, image.height,
            bytesPerRow: p.bytesPerRow,
            sensorOrientation: _selectedCam?.sensorOrientation ?? 0);
      }
    });
  }

  @override
  Future<void> stopImageStream() async {
    if (!_isStreaming) return;
    _isStreaming = false; if (kDebugMode) debugPrint('[scan] [5] image stream stop');
    final controller = _controller;
    if (controller != null && controller.value.isInitialized) {
      try {
        await controller.stopImageStream();
      } catch (_) {}
    }
  }

  @override
  Widget previewWidget() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return const SizedBox.shrink();
    return CameraPreview(controller);
  }
}
