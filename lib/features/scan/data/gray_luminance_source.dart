import 'dart:typed_data';
import 'package:zxing2/qrcode.dart';

class GrayLuminanceSource extends LuminanceSource {
  GrayLuminanceSource(Uint8List gray, super.width, super.height)
      : _matrix = gray.buffer.asInt8List(gray.offsetInBytes, width * height);

  final Int8List _matrix;

  @override
  Int8List getMatrix() => _matrix;

  @override
  Int8List getRow(int y, Int8List? row) {
    final start = y * width;
    final r = (row != null && row.length >= width) ? row : Int8List(width);
    for (int i = 0; i < width; i++) {
      r[i] = _matrix[start + i];
    }
    return r;
  }
}
