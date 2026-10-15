// Read dartcv4/lib/src/imgproc/imgproc.dart and dartcv4/lib/src/core/core.dart
import 'dart:math' as math;
import 'dart:ui';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import '../domain/quad.dart';
import 'filter_recipes.dart';

abstract final class OpencvTransformOps {
  static cv.Mat warpAndRotate(cv.Mat src, Quad quad, int rotation) {
    final w = src.width;
    final h = src.height;
    final tl = Offset(quad.topLeft.dx * w, quad.topLeft.dy * h);
    final tr = Offset(quad.topRight.dx * w, quad.topRight.dy * h);
    final br = Offset(quad.bottomRight.dx * w, quad.bottomRight.dy * h);
    final bl = Offset(quad.bottomLeft.dx * w, quad.bottomLeft.dy * h);

    double dist(Offset a, Offset b) => math.sqrt(
          (a.dx - b.dx) * (a.dx - b.dx) + (a.dy - b.dy) * (a.dy - b.dy),
        );

    final outW = math.max(1, math.max(dist(tl, tr), dist(bl, br)).round());
    final outH = math.max(1, math.max(dist(tl, bl), dist(tr, br)).round());

    final srcPts = cv.VecPoint2f.fromList([
      cv.Point2f(tl.dx, tl.dy),
      cv.Point2f(tr.dx, tr.dy),
      cv.Point2f(br.dx, br.dy),
      cv.Point2f(bl.dx, bl.dy),
    ]);
    final dstPts = cv.VecPoint2f.fromList([
      cv.Point2f(0, 0),
      cv.Point2f(outW.toDouble(), 0),
      cv.Point2f(outW.toDouble(), outH.toDouble()),
      cv.Point2f(0, outH.toDouble()),
    ]);

    cv.Mat? transform;
    cv.Mat? warped;
    try {
      transform = cv.getPerspectiveTransform2f(srcPts, dstPts);
      warped = cv.warpPerspective(src, transform, (outW, outH), flags: cv.INTER_LINEAR);
    } finally {
      srcPts.dispose();
      dstPts.dispose();
      transform?.dispose();
    }

    final rot = (rotation % 360 + 360) % 360;
    switch (rot) {
      case 0:
        return warped;
      case 90:
        final r = cv.rotate(warped, cv.ROTATE_90_CLOCKWISE);
        warped.dispose();
        return r;
      case 180:
        final r = cv.rotate(warped, cv.ROTATE_180);
        warped.dispose();
        return r;
      case 270:
        final r = cv.rotate(warped, cv.ROTATE_90_COUNTERCLOCKWISE);
        warped.dispose();
        return r;
      default:
        warped.dispose();
        throw ArgumentError.value(rotation, 'rotation', 'Must be 0, 90, 180, or 270');
    }
  }

  static cv.Mat warpRotateAndFilter({
    required cv.Mat src,
    required Quad quad,
    required int rotation,
    required String filterId,
  }) {
    final warpedRotated = warpAndRotate(src, quad, rotation);
    try {
      return FilterRecipes.apply(warpedRotated, filterId);
    } finally {
      warpedRotated.dispose();
    }
  }
}
