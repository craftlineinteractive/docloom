import 'dart:math' as math;
import 'dart:ui';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import '../domain/quad.dart';
import 'edge_detector_constants.dart';

class CandidateQuad {
  const CandidateQuad({
    required this.quad,
    required this.score,
    required this.areaRatio,
    required this.rectScore,
    required this.angleScore,
    required this.edgeSupport,
    this.rejectionReason,
  });

  final Quad quad;
  final double score;
  final double areaRatio;
  final double rectScore;
  final double angleScore;
  final double edgeSupport;
  final String? rejectionReason;

  bool get isAccepted => rejectionReason == null;
}

abstract final class EdgeDetectorEvaluator {
  static double computeEdgeSupport(List<cv.Point> pts, cv.Mat? gradientMat, int w, int h) {
    if (gradientMat == null || gradientMat.isEmpty) return 1.0;
    var totalGrad = 0.0;
    var sampleCount = 0;
    for (var i = 0; i < 4; i++) {
      final p1 = pts[i], p2 = pts[(i + 1) % 4];
      for (var s = 0; s <= 8; s++) {
        final t = s / 8.0;
        final sx = (p1.x + (p2.x - p1.x) * t).round().clamp(0, w - 1);
        final sy = (p1.y + (p2.y - p1.y) * t).round().clamp(0, h - 1);
        totalGrad += gradientMat.at<int>(sy, sx);
        sampleCount++;
      }
    }
    if (sampleCount == 0) return 0.5;
    final meanGrad = totalGrad / (sampleCount * 255.0);
    return 0.50 + 0.50 * meanGrad.clamp(0.0, 1.0);
  }

  static (Quad, double)? evaluateApprox(cv.VecPoint approx, int w, int h, [cv.Mat? gradMat]) {
    final cand = evaluateCandidate(approx, w, h, gradMat);
    if (!cand.isAccepted) return null;
    return (cand.quad, cand.score);
  }

  static CandidateQuad evaluateCandidate(cv.VecPoint approx, int w, int h, [cv.Mat? gradMat]) {
    if (approx.length != 4 || !cv.isContourConvex(approx)) {
      final quad = approx.length == 4
          ? Quad.fromUnordered(approx.toList().map((p) => Offset((p.x / w).clamp(0.0, 1.0), (p.y / h).clamp(0.0, 1.0))).toList())
          : Quad.unit();
      return CandidateQuad(
        quad: quad, score: 0.0, areaRatio: 0.0, rectScore: 0.0, angleScore: 0.0, edgeSupport: 0.0,
        rejectionReason: approx.length != 4 ? 'Not 4 points (${approx.length})' : 'Non-convex contour',
      );
    }

    final quadArea = cv.contourArea(approx);
    final areaRatio = quadArea / (w * h);
    final pts = approx.toList();
    final quad = Quad.fromUnordered(pts.map((p) => Offset((p.x / w).clamp(0.0, 1.0), (p.y / h).clamp(0.0, 1.0))).toList());

    if (areaRatio < kMinAreaRatio) {
      return CandidateQuad(quad: quad, score: 0.0, areaRatio: areaRatio, rectScore: 0.0, angleScore: 0.0, edgeSupport: 0.0, rejectionReason: 'Area ratio < ${(kMinAreaRatio * 100).toInt()}%');
    }
    if (areaRatio > kMaxAreaRatio) {
      return CandidateQuad(quad: quad, score: 0.0, areaRatio: areaRatio, rectScore: 0.0, angleScore: 0.0, edgeSupport: 0.0, rejectionReason: 'Area ratio > ${(kMaxAreaRatio * 100).toInt()}%');
    }

    var tl = false, tr = false, br = false, bl = false;
    for (final p in pts) {
      final nx = p.x / w, ny = p.y / h;
      if (nx <= kBorderMargin && ny <= kBorderMargin) tl = true;
      if (nx >= 1.0 - kBorderMargin && ny <= kBorderMargin) tr = true;
      if (nx >= 1.0 - kBorderMargin && ny >= 1.0 - kBorderMargin) br = true;
      if (nx <= kBorderMargin && ny >= 1.0 - kBorderMargin) bl = true;
    }
    if (tl && tr && br && bl) {
      return CandidateQuad(quad: quad, score: 0.0, areaRatio: areaRatio, rectScore: 0.0, angleScore: 0.0, edgeSupport: 0.0, rejectionReason: 'All 4 corners hug border');
    }

    final minRect = cv.minAreaRect(approx);
    final minRectArea = minRect.size.width * minRect.size.height;
    final rectScore = minRectArea > 0 ? math.min(1.0, quadArea / minRectArea) : 0.0;

    var angleSum = 0.0;
    for (var i = 0; i < 4; i++) {
      final pP = pts[(i + 3) % 4], pC = pts[i], pN = pts[(i + 1) % 4];
      final v1x = (pP.x - pC.x).toDouble(), v1y = (pP.y - pC.y).toDouble();
      final v2x = (pN.x - pC.x).toDouble(), v2y = (pN.y - pC.y).toDouble();
      final len1 = math.sqrt(v1x * v1x + v1y * v1y), len2 = math.sqrt(v2x * v2x + v2y * v2y);
      if (len1 > 0 && len2 > 0) {
        final cosVal = ((v1x * v2x + v1y * v2y) / (len1 * len2)).abs();
        angleSum += math.max(0.0, 1.0 - cosVal);
      }
    }
    final angleScore = angleSum / 4.0;

    var borderTouchCount = 0;
    for (final p in pts) {
      final nx = p.x / w, ny = p.y / h;
      if (nx <= kBorderMargin || nx >= 1.0 - kBorderMargin ||
          ny <= kBorderMargin || ny >= 1.0 - kBorderMargin) {
        borderTouchCount++;
      }
    }
    if (borderTouchCount >= 2 &&
        (rectScore < kBorderQuadMinRect || angleScore < kBorderQuadMinAngle)) {
      return CandidateQuad(
        quad: quad,
        score: 0.0,
        areaRatio: areaRatio,
        rectScore: rectScore,
        angleScore: angleScore,
        edgeSupport: 0.0,
        rejectionReason: 'Border candidate not a clear quad',
      );
    }

    final edgeSupport = computeEdgeSupport(pts, gradMat, w, h);
    final score = areaRatio * rectScore * angleScore * edgeSupport;

    if (score < kMinScoreThreshold) {
      return CandidateQuad(quad: quad, score: score, areaRatio: areaRatio, rectScore: rectScore, angleScore: angleScore, edgeSupport: edgeSupport, rejectionReason: 'Score < $kMinScoreThreshold');
    }

    return CandidateQuad(quad: quad, score: score, areaRatio: areaRatio, rectScore: rectScore, angleScore: angleScore, edgeSupport: edgeSupport);
  }
}
