import 'package:flutter/widgets.dart';

enum CameraFlash { off, on, auto }

enum CameraLens { back, front, external }

enum CameraPreset { low, medium, high, veryHigh, ultraHigh, max }

abstract interface class CameraService {
  Future<void> initialize({
    CameraPreset preset = CameraPreset.max,
    CameraLens lens = CameraLens.back,
  });

  Future<void> dispose();

  Future<void> setFlash(CameraFlash flash);

  Future<void> setFocusPoint(Offset point);

  Future<String> takePicture();

  List<CameraLens> get availableLenses;

  CameraLens get currentLens;

  CameraFlash get currentFlash;

  bool get isInitialized;

  double? get aspectRatio;

  Widget previewWidget();
}
