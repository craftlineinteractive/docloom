import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:zxing2/qrcode.dart';
import '../../../core/theme/app_sizes.dart';
import '../domain/qr_decoder.dart';
import 'gray_luminance_source.dart';

class ZxingQrDecoder implements QrDecoder {
  const ZxingQrDecoder();

  @override
  Future<String?> decodeGray(Uint8List gray, int width, int height) async {
    return Isolate.run(() => _decodeSync(gray, width, height));
  }

  static String? _decodeSync(Uint8List gray, int width, int height) {
    int w = width;
    int h = height;
    Uint8List bytes = gray;

    final longest = math.max(w, h);
    const maxDim = AppSizes.qrMaxDecodeDimension;
    if (longest > maxDim) {
      final scale = maxDim / longest;
      final targetW = (w * scale).round();
      final targetH = (h * scale).round();
      bytes = _downscale(bytes, w, h, targetW, targetH);
      w = targetW;
      h = targetH;
    }

    try {
      final source = GrayLuminanceSource(bytes, w, h);
      final bitmap = BinaryBitmap(HybridBinarizer(source));
      final reader = QRCodeReader();
      final result = reader.decode(bitmap);
      return result.text;
    } catch (_) {
      return null;
    }
  }

  static Uint8List _downscale(
    Uint8List src,
    int srcW,
    int srcH,
    int targetW,
    int targetH,
  ) {
    if (srcW == targetW && srcH == targetH) return src;
    final dst = Uint8List(targetW * targetH);
    final xRatio = (srcW << 16) ~/ targetW;
    final yRatio = (srcH << 16) ~/ targetH;
    for (int y = 0; y < targetH; y++) {
      final srcY = (y * yRatio) >> 16;
      final srcRowOffset = srcY * srcW;
      final dstRowOffset = y * targetW;
      for (int x = 0; x < targetW; x++) {
        final srcX = (x * xRatio) >> 16;
        dst[dstRowOffset + x] = src[srcRowOffset + srcX];
      }
    }
    return dst;
  }
}
