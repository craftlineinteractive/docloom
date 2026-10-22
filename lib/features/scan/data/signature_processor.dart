import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;
import 'package:opencv_dart/opencv_dart.dart' as cv;

class SignatureProcessor {
  const SignatureProcessor._();

  static const int maxWidth = 1000;
  static const int padding = 16;
  static const int inkThresholdAlpha = 25;

  static Future<String> process({
    required String srcPath,
    required String dstPath,
  }) =>
      Isolate.run(() => processSync(srcPath: srcPath, dstPath: dstPath));

  static String processSync({
    required String srcPath,
    required String dstPath,
  }) {
    final src = cv.imread(srcPath, flags: cv.IMREAD_COLOR);
    if (src.isEmpty) {
      src.dispose();
      throw ArgumentError('Failed to read signature image at $srcPath');
    }
    try {
      final gray = cv.cvtColor(src, cv.COLOR_BGR2GRAY);
      try {
        final w = gray.width;
        final h = gray.height;
        final bgra = cv.Mat.fromScalar(h, w, cv.MatType.CV_8UC4, cv.Scalar(0, 0, 0, 0));
        try {
          final box = _fillAlphaAndFindBounds(gray, bgra, w, h);
          return _cropResizeAndSave(bgra, box, w, h, dstPath);
        } finally {
          bgra.dispose();
        }
      } finally {
        gray.dispose();
      }
    } finally {
      src.dispose();
    }
  }

  static (int, int, int, int) _calcThresholds(cv.Mat gray, int total) {
    final hist = List<int>.filled(256, 0);
    final data = gray.data;
    for (int i = 0; i < total; i++) {
      hist[data[i]]++;
    }
    int cum = 0;
    int p5 = 50;
    int p90 = 230;
    final t5 = (total * 0.05).round();
    final t90 = (total * 0.90).round();
    for (int i = 0; i < 256; i++) {
      cum += hist[i];
      if (cum >= t5 && p5 == 50) p5 = i;
      if (cum >= t90) {
        p90 = i;
        break;
      }
    }
    final paper = math.max(120, p90 - 15);
    final ink = math.min(paper - 30, p5);
    return (paper, ink, 0, 0);
  }

  static (int, int, int, int) _fillAlphaAndFindBounds(
    cv.Mat gray,
    cv.Mat bgra,
    int w,
    int h,
  ) {
    final total = w * h;
    final (paper, ink, _, _) = _calcThresholds(gray, total);
    final range = math.max(1, paper - ink);

    final gData = gray.data;
    final bData = bgra.data;
    int minX = w, maxX = -1, minY = h, maxY = -1;

    for (int y = 0; y < h; y++) {
      final rowOffset = y * w;
      for (int x = 0; x < w; x++) {
        final g = gData[rowOffset + x];
        int alpha = 0;
        if (g < paper) {
          alpha = ((paper - g) / range * 255).round().clamp(0, 255);
        }
        bData[(rowOffset + x) * 4 + 3] = alpha;
        if (alpha > inkThresholdAlpha) {
          if (x < minX) minX = x;
          if (x > maxX) maxX = x;
          if (y < minY) minY = y;
          if (y > maxY) maxY = y;
        }
      }
    }
    return (minX, maxX, minY, maxY);
  }

  static String _cropResizeAndSave(
    cv.Mat bgra,
    (int, int, int, int) box,
    int w,
    int h,
    String dstPath,
  ) {
    var (minX, maxX, minY, maxY) = box;
    if (maxX < minX) {
      minX = 0;
      maxX = w - 1;
      minY = 0;
      maxY = h - 1;
    } else {
      minX = math.max(0, minX - padding);
      maxX = math.min(w - 1, maxX + padding);
      minY = math.max(0, minY - padding);
      maxY = math.min(h - 1, maxY + padding);
    }

    final cropped = bgra.rowRange(minY, maxY + 1).colRange(minX, maxX + 1);
    try {
      cv.Mat toSave = cropped;
      cv.Mat? resized;
      if (cropped.width > maxWidth) {
        final scale = maxWidth / cropped.width;
        final targetH = math.max(1, (cropped.height * scale).round());
        resized = cv.resize(cropped, (maxWidth, targetH), interpolation: cv.INTER_AREA);
        toSave = resized;
      }
      try {
        final parent = File(dstPath).parent;
        if (!parent.existsSync()) parent.createSync(recursive: true);
        final ok = cv.imwrite(dstPath, toSave);
        if (!ok) throw StateError('Failed to write signature PNG to $dstPath');
        return dstPath;
      } finally {
        resized?.dispose();
      }
    } finally {
      cropped.dispose();
    }
  }
}
