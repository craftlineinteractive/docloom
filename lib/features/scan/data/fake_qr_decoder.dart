import 'dart:typed_data';
import '../domain/qr_decoder.dart';

class FakeQrDecoder implements QrDecoder {
  String? nextResult;
  int decodeCallCount = 0;

  @override
  Future<String?> decodeGray(Uint8List gray, int width, int height) async {
    decodeCallCount++;
    return nextResult;
  }
}
