import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../domain/camera_service.dart';

class FakeCameraService implements CameraService {
  FakeCameraService({
    this.picturePathToReturn = '/fake/path/scanned.jpg',
    List<CameraLens>? availableLenses,
  }) : availableLensesList = availableLenses ??
            [CameraLens.back, CameraLens.front];

  int initializeCount = 0;
  int disposeCount = 0;
  int takePictureCount = 0;
  bool shouldFailInitialize = false;
  String picturePathToReturn;
  Offset? lastFocusPoint;

  List<CameraLens> availableLensesList;
  CameraLens _currentLens = CameraLens.back;
  CameraFlash _currentFlash = CameraFlash.off;
  bool _isInitialized = false;
  bool _isStreaming = false;
  CameraFrameCallback? _streamCallback;
  DateTime? _lastFrameTime;

  @override
  bool get isInitialized => _isInitialized;

  @override
  DateTime? get lastFrameTime => _lastFrameTime;
  set lastFrameTime(DateTime? value) => _lastFrameTime = value;

  @override
  CameraLens get currentLens => _currentLens;

  @override
  CameraFlash get currentFlash => _currentFlash;

  @override
  double? get aspectRatio => 4 / 3;

  @override
  bool get isStreamingImages => _isStreaming;

  @override
  List<CameraLens> get availableLenses => List.unmodifiable(availableLensesList);

  @override
  Future<void> initialize({
    CameraPreset preset = CameraPreset.max,
    CameraLens lens = CameraLens.back,
  }) async {
    initializeCount++;
    if (shouldFailInitialize) {
      _isInitialized = false;
      throw Exception('Camera initialization failed');
    }
    _currentLens = lens;
    _isInitialized = true;
    _lastFrameTime = DateTime.now();
  }

  @override
  Future<void> dispose() async {
    disposeCount++;
    _isStreaming = false;
    _isInitialized = false;
    _streamCallback = null;
    _lastFrameTime = null;
  }

  @override
  Future<void> setFlash(CameraFlash flash) async {
    _currentFlash = flash;
  }

  @override
  Future<void> setFocusPoint(Offset point) async {
    lastFocusPoint = point;
  }

  @override
  Future<String> takePicture() async {
    takePictureCount++;
    if (!_isInitialized) {
      throw StateError('Camera not initialized');
    }
    return picturePathToReturn;
  }

  @override
  Future<void> startImageStream(CameraFrameCallback onFrame) async {
    _isStreaming = true;
    if (kDebugMode) debugPrint('[scan] [4] image stream start');
    _streamCallback = onFrame;
  }

  @override
  Future<void> stopImageStream() async {
    _isStreaming = false;
    if (kDebugMode) debugPrint('[scan] [5] image stream stop');
    _streamCallback = null;
  }

  void emitFrame(Uint8List gray, int width, int height) {
    _lastFrameTime = DateTime.now();
    if (_isStreaming && _streamCallback != null) {
      _streamCallback!(gray, width, height);
    }
  }

  @override
  Widget previewWidget() {
    return Container(
      key: const ValueKey('fake_camera_preview'),
      color: Colors.black,
    );
  }
}
