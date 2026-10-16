// Read dartcv4/lib/src/imgproc/imgproc.dart and dartcv4/lib/src/core/core.dart
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import '../domain/quad.dart';
import 'edge_detector_evaluator.dart';

const int kDetectMaxSide = 500;
const int kBlurKernelSize = 5;
const double kCannySigma = 0.33;
const double kSensitiveCannyLow = 20.0;
const double kSensitiveCannyHigh = 60.0;
const int kMorphKernelSize = 5;
const int kDilateIterations = 2;
const List<double> kEpsilonRatios = [0.02, 0.025, 0.03, 0.035, 0.04, 0.05, 0.06, 0.07, 0.08];
const List<int> kAdaptiveBlockSizes = [25, 35, 45];
const double kAdaptiveC = 10.0;
const List<double> kLuminanceThresholds = [170.0, 225.0];

abstract final class EdgeDetectorOps {
  static int computeMedian(Uint8List data) {
    final counts = Int32List(256);
    for (var i = 0; i < data.length; i++) {
      counts[data[i]]++;
    }
    final half = data.length ~/ 2;
    var acc = 0;
    for (var i = 0; i < 256; i++) {
      acc += counts[i];
      if (acc >= half) return i;
    }
    return 128;
  }

  static Quad? detectFromMat(cv.Mat src) {
    if (src.isEmpty) return null;
    final longest = math.max(src.width, src.height);
    final scale = longest > kDetectMaxSide ? kDetectMaxSide / longest : 1.0;
    final tW = (src.width * scale).round(), tH = (src.height * scale).round();
    final resized = cv.resize(src, (tW, tH), interpolation: cv.INTER_AREA);

    final gray = cv.cvtColor(resized, cv.COLOR_BGR2GRAY);
    final blurred = cv.gaussianBlur(gray, (kBlurKernelSize, kBlurKernelSize), 0.0);
    final morph = cv.getStructuringElement(cv.MORPH_RECT, (kMorphKernelSize, kMorphKernelSize));

    Quad? bestQuad;
    double bestScore = 0.0;

    void testBinary(cv.Mat bin) {
      for (final mode in [cv.RETR_EXTERNAL, cv.RETR_LIST]) {
        final (contours, _) = cv.findContours(bin, mode, cv.CHAIN_APPROX_SIMPLE);
        for (final c in contours) {
          if (cv.contourArea(c) < kMinAreaRatio * tW * tH) continue;
          final peri = cv.arcLength(c, true);
          for (final eps in kEpsilonRatios) {
            final approx = cv.approxPolyDP(c, eps * peri, true);
            final result = EdgeDetectorEvaluator.evaluateApprox(approx, tW, tH);
            if (result != null && result.$2 > bestScore) {
              bestScore = result.$2;
              bestQuad = result.$1;
            }
            approx.dispose();
          }
        }
        contours.dispose();
      }
    }

    // Strategy 1: Canny (median thresholds + sensitive low Canny)
    final med = computeMedian(blurred.data);
    final low = math.max(0.0, (1.0 - kCannySigma) * med);
    final high = math.min(255.0, (1.0 + kCannySigma) * med);
    final edges = cv.canny(blurred, low, high);
    final dilEdges = cv.dilate(edges, morph, iterations: kDilateIterations);
    testBinary(dilEdges);
    final closeEdges = cv.morphologyEx(edges, cv.MORPH_CLOSE, morph);
    testBinary(closeEdges);
    edges.dispose(); dilEdges.dispose(); closeEdges.dispose();

    final sens = cv.canny(blurred, kSensitiveCannyLow, kSensitiveCannyHigh);
    final dilSens = cv.dilate(sens, morph, iterations: kDilateIterations);
    testBinary(dilSens);
    sens.dispose(); dilSens.dispose();

    // Strategy 2: Otsu, Adaptive & Luminance
    final (_, otsu) = cv.threshold(blurred, 0, 255, cv.THRESH_BINARY | cv.THRESH_OTSU);
    final closeOtsu = cv.morphologyEx(otsu, cv.MORPH_CLOSE, morph);
    testBinary(closeOtsu);
    closeOtsu.dispose(); otsu.dispose();

    final (_, invOtsu) = cv.threshold(blurred, 0, 255, cv.THRESH_BINARY_INV | cv.THRESH_OTSU);
    final closeInvOtsu = cv.morphologyEx(invOtsu, cv.MORPH_CLOSE, morph);
    testBinary(closeInvOtsu);
    closeInvOtsu.dispose(); invOtsu.dispose();

    for (final bs in kAdaptiveBlockSizes) {
      final adapt = cv.adaptiveThreshold(blurred, 255, cv.ADAPTIVE_THRESH_GAUSSIAN_C, cv.THRESH_BINARY, bs, kAdaptiveC);
      final closeAdapt = cv.morphologyEx(adapt, cv.MORPH_CLOSE, morph);
      testBinary(closeAdapt);
      closeAdapt.dispose(); adapt.dispose();
    }
    for (final thVal in kLuminanceThresholds) {
      final (_, th) = cv.threshold(blurred, thVal, 255, cv.THRESH_BINARY);
      final closeTh = cv.morphologyEx(th, cv.MORPH_CLOSE, morph);
      testBinary(closeTh);
      closeTh.dispose(); th.dispose();
    }

    // Strategy 3: Saturation channel
    final hsv = cv.cvtColor(resized, cv.COLOR_BGR2HSV);
    final ch = cv.split(hsv);
    final satBlur = cv.gaussianBlur(ch[1], (kBlurKernelSize, kBlurKernelSize), 0.0);
    final (_, satOtsu) = cv.threshold(satBlur, 0, 255, cv.THRESH_BINARY | cv.THRESH_OTSU);
    final closeSatOtsu = cv.morphologyEx(satOtsu, cv.MORPH_CLOSE, morph);
    testBinary(closeSatOtsu);
    closeSatOtsu.dispose(); satOtsu.dispose();

    final (_, satInv) = cv.threshold(satBlur, 0, 255, cv.THRESH_BINARY_INV | cv.THRESH_OTSU);
    final closeSatInv = cv.morphologyEx(satInv, cv.MORPH_CLOSE, morph);
    testBinary(closeSatInv);
    closeSatInv.dispose(); satInv.dispose(); satBlur.dispose(); ch.dispose(); hsv.dispose();

    morph.dispose(); gray.dispose(); blurred.dispose(); resized.dispose();
    return bestQuad;
  }
}
