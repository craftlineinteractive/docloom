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

  @override
  bool get isInitialized => _isInitialized;

  @override
  CameraLens get currentLens => _currentLens;

  @override
  CameraFlash get currentFlash => _currentFlash;

  @override
  List<CameraLens> get availableLenses => List.unmodifiable(availableLensesList);

  @override
  Future<void> initialize({
    CameraPreset preset = CameraPreset.high,
    CameraLens lens = CameraLens.back,
  }) async {
    initializeCount++;
    if (shouldFailInitialize) {
      _isInitialized = false;
      throw Exception('Camera initialization failed');
    }
    _currentLens = lens;
    _isInitialized = true;
  }

  @override
  Future<void> dispose() async {
    disposeCount++;
    _isInitialized = false;
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
  Widget previewWidget() {
    return Container(
      key: const ValueKey('fake_camera_preview'),
      color: Colors.black,
    );
  }
}
