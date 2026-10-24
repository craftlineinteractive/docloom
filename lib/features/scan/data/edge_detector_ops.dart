import 'dart:math' as math;
import 'dart:typed_data';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import '../domain/quad.dart';
import 'edge_detector_constants.dart';
import 'edge_detector_debug_trace.dart';
import 'edge_detector_evaluator.dart';
import 'edge_detector_strategies.dart';

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

  static Quad? detectFromMat(cv.Mat src) => detectWithTrace(src).$1;

  static (Quad?, EdgeDetectionDebugTrace?) detectWithTrace(cv.Mat src, {bool recordTrace = false}) {
    if (src.isEmpty) return (null, null);
    final longest = math.max(src.width, src.height);
    final scale = longest > kDetectMaxSide ? kDetectMaxSide / longest : 1.0;
    final tW = (src.width * scale).round(), tH = (src.height * scale).round();
    final resized = cv.resize(src, (tW, tH), interpolation: cv.INTER_AREA);

    final gray = cv.cvtColor(resized, cv.COLOR_BGR2GRAY);
    final blurred = cv.gaussianBlur(gray, (kBlurKernelSize, kBlurKernelSize), 0.0);
    final morph = cv.getStructuringElement(cv.MORPH_RECT, (kMorphKernelSize, kMorphKernelSize));

    final gradX = cv.sobel(blurred, cv.MatType.CV_16S, 1, 0);
    final gradY = cv.sobel(blurred, cv.MatType.CV_16S, 0, 1);
    final absX = cv.convertScaleAbs(gradX), absY = cv.convertScaleAbs(gradY);
    final gradMat = cv.addWeighted(absX, 0.5, absY, 0.5, 0.0);
    gradX.dispose(); gradY.dispose(); absX.dispose(); absY.dispose();

    Quad? bestQuad;
    double bestScore = 0.0;
    final candidates = <CandidateQuad>[];
    cv.Mat? sampleEdgesMat, sampleMaskMat;

    void testCandidate(cv.VecPoint approx) {
      final cand = EdgeDetectorEvaluator.evaluateCandidate(approx, tW, tH, gradMat);
      if (recordTrace) candidates.add(cand);
      if (cand.isAccepted && cand.score > bestScore) {
        bestScore = cand.score;
        bestQuad = cand.quad;
      }
    }

    void testBinary(cv.Mat bin, {bool isEdges = false, bool isMask = false}) {
      if (recordTrace && isEdges && sampleEdgesMat == null) sampleEdgesMat = bin.clone();
      if (recordTrace && isMask && sampleMaskMat == null) sampleMaskMat = bin.clone();

      final (contours, _) = cv.findContours(bin, cv.RETR_EXTERNAL, cv.CHAIN_APPROX_SIMPLE);
        for (final c in contours) {
          if (cv.contourArea(c) < kMinAreaRatio * tW * tH) continue;
          final peri = cv.arcLength(c, true);
          var found4 = false;

          for (final eps in kEpsilonRatios) {
            final approx = cv.approxPolyDP(c, eps * peri, true);
            if (approx.length == 4 && cv.isContourConvex(approx)) {
              testCandidate(approx);
              found4 = true;
            }
            approx.dispose();
          }

          if (!found4) {
            final hullMat = cv.convexHull(c, returnPoints: true);
            final hull = cv.VecPoint.fromMat(hullMat);
            hullMat.dispose();
            final hPeri = cv.arcLength(hull, true);
            for (final eps in kEpsilonRatios) {
              final approx = cv.approxPolyDP(hull, eps * hPeri, true);
              if (approx.length == 4 && cv.isContourConvex(approx)) {
                testCandidate(approx);
                found4 = true;
              }
              approx.dispose();
            }
            hull.dispose();
          }
        }
        contours.dispose();
      }

    final med = computeMedian(blurred.data);
    EdgeDetectorStrategies.runCanny(blurred, morph, med, testBinary);
    EdgeDetectorStrategies.runThresholds(blurred, resized, morph, testBinary);

    EdgeDetectionDebugTrace? trace;
    if (recordTrace) {
      final edgesMat = sampleEdgesMat ?? cv.Mat.zeros(tH, tW, cv.MatType.CV_8UC1);
      final maskMat = sampleMaskMat ?? cv.Mat.zeros(tH, tW, cv.MatType.CV_8UC1);
      trace = EdgeDetectionDebugTrace(
        grayBytes: EdgeDetectionDebugTrace.matToPng(gray),
        blurredBytes: EdgeDetectionDebugTrace.matToPng(blurred),
        edgesBytes: EdgeDetectionDebugTrace.matToPng(edgesMat),
        maskBytes: EdgeDetectionDebugTrace.matToPng(maskMat),
        candidates: candidates,
        finalQuad: bestQuad,
        sourceBytes: EdgeDetectionDebugTrace.matToPng(resized),
      );
      sampleEdgesMat?.dispose();
      sampleMaskMat?.dispose();
      if (sampleEdgesMat == null) edgesMat.dispose();
      if (sampleMaskMat == null) maskMat.dispose();
    }

    morph.dispose(); gradMat.dispose(); gray.dispose(); blurred.dispose(); resized.dispose();
    return (bestQuad, trace);
  }
}
