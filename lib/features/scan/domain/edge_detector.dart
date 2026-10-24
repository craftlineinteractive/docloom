import 'dart:typed_data';
import '../data/edge_detector_debug_trace.dart';
import 'quad.dart';

abstract interface class EdgeDetector {
  Future<Quad?> detectFromFile(String previewPath);
  Future<Quad?> detectFromGray(
    Uint8List gray,
    int width,
    int height, {
    int sensorOrientation = 0,
    int bytesPerRow = 0,
  });
  Future<(Quad?, EdgeDetectionDebugTrace?)> detectFromFileWithTrace(String path);
}
