import 'dart:typed_data';
import '../domain/edge_detector.dart';
import '../domain/quad.dart';
import 'edge_detector_debug_trace.dart';

class FakeEdgeDetector implements EdgeDetector {
  FakeEdgeDetector({this.stubQuad});

  Quad? stubQuad;
  String? lastDetectPath;
  Uint8List? lastDetectGray;
  int callCount = 0;

  @override
  Future<Quad?> detectFromFile(String previewPath) async {
    callCount++;
    lastDetectPath = previewPath;
    return stubQuad;
  }

  @override
  Future<Quad?> detectFromGray(
    Uint8List gray,
    int width,
    int height, {
    int sensorOrientation = 0,
    int bytesPerRow = 0,
  }) async {
    callCount++;
    lastDetectGray = gray;
    return stubQuad;
  }

  @override
  Future<(Quad?, EdgeDetectionDebugTrace?)> detectFromFileWithTrace(String path) async {
    callCount++;
    lastDetectPath = path;
    return (stubQuad, null);
  }
}
