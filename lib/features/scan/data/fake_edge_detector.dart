import 'dart:typed_data';
import '../domain/edge_detector.dart';
import '../domain/quad.dart';

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
  Future<Quad?> detectFromGray(Uint8List gray, int width, int height) async {
    callCount++;
    lastDetectGray = gray;
    return stubQuad;
  }
}
