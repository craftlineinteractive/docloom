import 'dart:math' as math;
import 'dart:typed_data';
import 'package:opencv_dart/opencv_dart.dart' as cv;

abstract final class FilterOpsHelper {
  static cv.Mat flattenShadows(cv.Mat src) {
    final scale = 400.0 / math.max(src.width, src.height);
    final smallW = (src.width * scale).round();
    final smallH = (src.height * scale).round();

    final channels = cv.split(src);
    final flattenedChannels = <cv.Mat>[];
    final kernel = cv.getStructuringElement(cv.MORPH_RECT, (25, 25));
    try {
      for (int i = 0; i < channels.length; i++) {
        final ch = channels[i];
        final small = cv.resize(ch, (smallW, smallH), interpolation: cv.INTER_AREA);
        final closed = cv.morphologyEx(small, cv.MORPH_CLOSE, kernel);
        small.dispose();
        final blurred = cv.medianBlur(closed, 25);
        closed.dispose();
        final bg = cv.resize(blurred, (ch.width, ch.height), interpolation: cv.INTER_CUBIC);
        blurred.dispose();

        final div = cv.divide(ch, bg, scale: 255.0);
        bg.dispose();
        flattenedChannels.add(div);
      }
      final mv = cv.VecMat.fromList(flattenedChannels);
      try {
        return cv.merge(mv);
      } finally {
        mv.dispose();
      }
    } finally {
      kernel.dispose();
      channels.dispose();
      for (final m in flattenedChannels) {
        m.dispose();
      }
    }
  }

  static cv.Mat levelsStretch(cv.Mat src, {double lowPct = 0.01, double highPct = 0.99}) {
    final gray = cv.cvtColor(src, cv.COLOR_BGR2GRAY);
    final bytes = gray.data;
    final counts = List<int>.filled(256, 0);
    for (int i = 0; i < bytes.length; i++) {
      counts[bytes[i]]++;
    }
    gray.dispose();

    final total = bytes.length;
    final targetLow = (total * lowPct).round();
    final targetHigh = (total * highPct).round();
    int cumulative = 0;
    int p1 = 0;
    int p99 = 255;
    for (int i = 0; i < 256; i++) {
      cumulative += counts[i];
      if (cumulative >= targetLow && p1 == 0) p1 = i;
      if (cumulative >= targetHigh) { p99 = i; break; }
    }

    final range = math.max(1, p99 - p1);
    final lutData = Uint8List.fromList(List.generate(256, (i) => (((i - p1) * 255) / range).clamp(0, 255).round()));
    final lutMat = cv.Mat.fromList(1, 256, cv.MatType.CV_8UC1, lutData);
    try {
      return cv.LUT(src, lutMat);
    } finally {
      lutMat.dispose();
    }
  }

  static cv.Mat applyClahe(cv.Mat src, {double clipLimit = 2.0, (int, int) tileGridSize = (8, 8)}) {
    final lab = cv.cvtColor(src, cv.COLOR_BGR2Lab);
    final labChannels = cv.split(lab);
    lab.dispose();

    final clahe = cv.createCLAHE(clipLimit: clipLimit, tileGridSize: tileGridSize);
    final enhancedL = clahe.apply(labChannels[0]);
    clahe.dispose();
    labChannels[0].dispose();

    final mergedLabVec = cv.VecMat.fromList([enhancedL, labChannels[1], labChannels[2]]);
    final mergedLab = cv.merge(mergedLabVec);
    mergedLabVec.dispose();
    enhancedL.dispose();
    labChannels[1].dispose();
    labChannels[2].dispose();
    labChannels.dispose();

    final bgr = cv.cvtColor(mergedLab, cv.COLOR_Lab2BGR);
    mergedLab.dispose();
    return bgr;
  }

  static cv.Mat unsharpMask(cv.Mat src, {double amount = 0.6}) {
    final s = math.min(src.width, src.height);
    final radius = math.max(1, (s * 0.002).round() | 1);
    final kSize = (radius * 2 + 1, radius * 2 + 1);
    final blurred = cv.gaussianBlur(src, kSize, 0);
    try {
      return cv.addWeighted(src, 1.0 + amount, blurred, -amount, 0.0);
    } finally {
      blurred.dispose();
    }
  }

  static cv.Mat boostChroma(cv.Mat src, {double chromaMultiplier = 1.18, double gamma = 1.0}) {
    final lab = cv.cvtColor(src, cv.COLOR_BGR2Lab);
    final labChannels = cv.split(lab);
    lab.dispose();

    cv.Mat lMat = labChannels[0];
    if (gamma != 1.0) {
      final lutData = Uint8List(256);
      for (int i = 0; i < 256; i++) {
        lutData[i] = (math.pow(i / 255.0, gamma) * 255.0).clamp(0, 255).round();
      }
      final lutMat = cv.Mat.fromList(1, 256, cv.MatType.CV_8UC1, lutData);
      final liftedL = cv.LUT(lMat, lutMat);
      lutMat.dispose();
      lMat.dispose();
      lMat = liftedL;
    }

    final lutChroma = Uint8List(256);
    for (int i = 0; i < 256; i++) {
      lutChroma[i] = ((i - 128) * chromaMultiplier + 128).clamp(0, 255).round();
    }
    final lutMatC = cv.Mat.fromList(1, 256, cv.MatType.CV_8UC1, lutChroma);
    final boostedA = cv.LUT(labChannels[1], lutMatC);
    final boostedB = cv.LUT(labChannels[2], lutMatC);
    lutMatC.dispose();
    for (final ch in labChannels) { ch.dispose(); }
    labChannels.dispose();

    final mergedLabVec = cv.VecMat.fromList([lMat, boostedA, boostedB]);
    final mergedLab = cv.merge(mergedLabVec);
    mergedLabVec.dispose();
    for (final m in [lMat, boostedA, boostedB]) { m.dispose(); }

    final bgr = cv.cvtColor(mergedLab, cv.COLOR_Lab2BGR);
    mergedLab.dispose();
    return bgr;
  }
}
