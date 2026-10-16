import 'dart:math' as math;
import 'dart:ui';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import '../domain/quad.dart';

const double kMinAreaRatio = 0.20;
const double kMaxAreaRatio = 0.95;
const double kBorderMargin = 0.015;
const double kMinScoreThreshold = 0.10;

abstract final class EdgeDetectorEvaluator {
  static (Quad, double)? evaluateApprox(cv.VecPoint approx, int w, int h) {
    if (approx.length != 4 || !cv.isContourConvex(approx)) return null;
    final quadArea = cv.contourArea(approx);
    final areaRatio = quadArea / (w * h);
    if (areaRatio < kMinAreaRatio || areaRatio > kMaxAreaRatio) return null;

    final pts = approx.toList();
    var tl = false, tr = false, br = false, bl = false;
    for (final p in pts) {
      final nx = p.x / w, ny = p.y / h;
      if (nx <= kBorderMargin && ny <= kBorderMargin) tl = true;
      if (nx >= 1.0 - kBorderMargin && ny <= kBorderMargin) tr = true;
      if (nx >= 1.0 - kBorderMargin && ny >= 1.0 - kBorderMargin) br = true;
      if (nx <= kBorderMargin && ny >= 1.0 - kBorderMargin) bl = true;
    }
    // Reject if all 4 corners hug the canvas borders
    if (tl && tr && br && bl) return null;

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
    final score = areaRatio * rectScore * angleScore;
    if (score < kMinScoreThreshold) return null;

    final quad = Quad.fromUnordered(pts.map((p) => Offset(p.x / w, p.y / h)).toList());
    return (quad, score);
  }
}
