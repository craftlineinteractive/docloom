// ignore_for_file: avoid_print
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr/qr.dart';
import 'package:docloom/features/scan/data/zxing_qr_decoder.dart';

Uint8List _createQrFrame(String text, int frameW, int frameH) {
  final frame = Uint8List(frameW * frameH)..fillRange(0, frameW * frameH, 200);
  final qrCode = QrCode(payload: QrPayload.fromString(text), errorCorrectLevel: QrErrorCorrectLevel.medium);
  final qrImage = QrImage(qrCode);
  final count = qrImage.moduleCount;
  const scale = 8;
  final qrSize = count * scale;
  final startX = (frameW - qrSize) ~/ 2;
  final startY = (frameH - qrSize) ~/ 2;

  for (int my = 0; my < count; my++) {
    for (int mx = 0; mx < count; mx++) {
      if (qrImage.isDark(my, mx)) {
        for (int sy = 0; sy < scale; sy++) {
          final row = (startY + my * scale + sy) * frameW;
          for (int sx = 0; sx < scale; sx++) {
            frame[row + startX + mx * scale + sx] = 20;
          }
        }
      }
    }
  }
  return frame;
}

void main() {
  group('ZxingQrDecoder', () {
    const decoder = ZxingQrDecoder();

    test('decodes valid QR fixture generated with pure Dart qr package', () async {
      final frame = _createQrFrame('https://docloom.app/invite', 800, 600);
      final decoded = await decoder.decodeGray(frame, 800, 600);
      expect(decoded, 'https://docloom.app/invite');
    });

    test('returns null for blank / noise frames', () async {
      final blank = Uint8List(400 * 400)..fillRange(0, 400 * 400, 180);
      final decoded = await decoder.decodeGray(blank, 400, 400);
      expect(decoded, isNull);
    });

    test('measures decode time per frame on 1920x1080 Y-plane fixture over 20 runs', () async {
      const w = 1920;
      const h = 1080;
      final frame = _createQrFrame('https://docloom.app/scan/bench-payload-12345', w, h);

      // Warmup
      final warmup = await decoder.decodeGray(frame, w, h);
      expect(warmup, 'https://docloom.app/scan/bench-payload-12345');

      final runTimesMs = <int>[];
      for (int i = 0; i < 20; i++) {
        final sw = Stopwatch()..start();
        final result = await decoder.decodeGray(frame, w, h);
        sw.stop();
        expect(result, 'https://docloom.app/scan/bench-payload-12345');
        runTimesMs.add(sw.elapsedMilliseconds);
      }

      final mean = runTimesMs.reduce((a, b) => a + b) / runTimesMs.length;
      final worst = runTimesMs.reduce(math.max);

      print('QR Decode Benchmark (20 runs): $runTimesMs');
      print('Mean decode time: ${mean.toStringAsFixed(2)} ms');
      print('Worst decode time: $worst ms');

      expect(mean, lessThan(150.0), reason: 'Mean decode time must be strictly below 150 ms');
    });
  });
}
