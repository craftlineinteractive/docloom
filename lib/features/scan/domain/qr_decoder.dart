import 'dart:typed_data';

abstract interface class QrDecoder {
  Future<String?> decodeGray(Uint8List gray, int width, int height);
}
