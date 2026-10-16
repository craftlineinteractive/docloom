import 'dart:typed_data';
import 'quad.dart';

abstract interface class EdgeDetector {
  Future<Quad?> detectFromFile(String previewPath);
  Future<Quad?> detectFromGray(Uint8List gray, int width, int height);
}
