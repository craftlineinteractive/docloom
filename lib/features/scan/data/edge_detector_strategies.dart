import 'dart:math' as math;
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'edge_detector_constants.dart';

typedef BinaryTestCallback =
    void Function(cv.Mat bin, {bool isEdges, bool isMask});

abstract final class EdgeDetectorStrategies {
  static void runCanny(
    cv.Mat blurred,
    cv.Mat morph,
    int median,
    BinaryTestCallback test,
  ) {
    final low = math.max(0.0, (1.0 - kCannySigma) * median);
    final high = math.min(255.0, (1.0 + kCannySigma) * median);
    final edges1 = cv.canny(blurred, low, high);
    final dil1 = cv.dilate(edges1, morph, iterations: kDilateIterations);
    final close1 = cv.morphologyEx(edges1, cv.MORPH_CLOSE, morph);
    test(dil1, isEdges: true);
    test(close1);
    edges1.dispose();
    dil1.dispose();
    close1.dispose();

    final edges2 = cv.canny(blurred, kSensitiveCannyLow, kSensitiveCannyHigh);
    final dil2 = cv.dilate(edges2, morph, iterations: kDilateIterations);
    test(dil2);
    edges2.dispose();
    dil2.dispose();

    final edges3 = cv.canny(
      blurred,
      kSensitiveCannyLow * 0.7,
      kSensitiveCannyHigh * 0.7,
    );
    final close3 = cv.morphologyEx(edges3, cv.MORPH_CLOSE, morph);
    test(close3);
    edges3.dispose();
    close3.dispose();
  }

  static void runThresholds(
    cv.Mat blurred,
    cv.Mat resized,
    cv.Mat morph,
    BinaryTestCallback test,
  ) {
    final (_, otsu) = cv.threshold(blurred, 0, 255, cv.THRESH_BINARY | cv.THRESH_OTSU);
    final closeOtsu = cv.morphologyEx(otsu, cv.MORPH_CLOSE, morph);
    test(closeOtsu, isMask: true);
    closeOtsu.dispose();
    otsu.dispose();

    for (final bs in kAdaptiveBlockSizes) {
      final adapt = cv.adaptiveThreshold(
        blurred,
        255,
        cv.ADAPTIVE_THRESH_GAUSSIAN_C,
        cv.THRESH_BINARY,
        bs,
        kAdaptiveC,
      );
      final closeAdapt = cv.morphologyEx(adapt, cv.MORPH_CLOSE, morph);
      test(closeAdapt);
      closeAdapt.dispose();
      adapt.dispose();
    }

    for (final thVal in kLuminanceThresholds) {
      final (_, th) = cv.threshold(blurred, thVal, 255, cv.THRESH_BINARY);
      final closeTh = cv.morphologyEx(th, cv.MORPH_CLOSE, morph);
      test(closeTh);
      closeTh.dispose();
      th.dispose();
    }

    final hsv = cv.cvtColor(resized, cv.COLOR_BGR2HSV);
    final hsvCh = cv.split(hsv);
    final satBlur = cv.gaussianBlur(hsvCh[1], (
      kBlurKernelSize,
      kBlurKernelSize,
    ), 0.0);
    final (_, satOtsu) = cv.threshold(
      satBlur,
      0,
      255,
      cv.THRESH_BINARY | cv.THRESH_OTSU,
    );
    final closeSat = cv.morphologyEx(satOtsu, cv.MORPH_CLOSE, morph);
    test(closeSat);
    closeSat.dispose();
    satOtsu.dispose();
    satBlur.dispose();
    hsvCh.dispose();
    hsv.dispose();
  }
}
