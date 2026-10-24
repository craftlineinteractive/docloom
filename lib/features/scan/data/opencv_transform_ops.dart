import 'dart:ui';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import '../domain/perspective_aspect_helper.dart';
import '../domain/quad.dart';
import 'filter_recipes.dart';

abstract final class OpencvTransformOps {
  static cv.Mat warpAndRotate(cv.Mat src, Quad quad, int rotation) {
    final imageSize = Size(src.width.toDouble(), src.height.toDouble());
    final pixelQuad = quad.toPixels(imageSize);
    final outputSize = PerspectiveAspectHelper.recoverOutputDimensions(
      pixelQuad: pixelQuad,
      imageSize: imageSize,
    );
    final outW = outputSize.width.round();
    final outH = outputSize.height.round();

    final srcPts = cv.VecPoint2f.fromList([
      cv.Point2f(pixelQuad.topLeft.dx, pixelQuad.topLeft.dy),
      cv.Point2f(pixelQuad.topRight.dx, pixelQuad.topRight.dy),
      cv.Point2f(pixelQuad.bottomRight.dx, pixelQuad.bottomRight.dy),
      cv.Point2f(pixelQuad.bottomLeft.dx, pixelQuad.bottomLeft.dy),
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
    int? targetWidth,
    int? targetHeight,
  }) {
    var warpedRotated = warpAndRotate(src, quad, rotation);
    if (targetWidth != null &&
        targetHeight != null &&
        (warpedRotated.width != targetWidth ||
            warpedRotated.height != targetHeight)) {
      final resized = cv.resize(
        warpedRotated,
        (targetWidth, targetHeight),
        interpolation: cv.INTER_AREA,
      );
      warpedRotated.dispose();
      warpedRotated = resized;
    }
    try {
      return FilterRecipes.apply(warpedRotated, filterId);
    } finally {
      warpedRotated.dispose();
    }
  }
}
