import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import '../domain/image_engine.dart';
import '../domain/quad.dart';

class OpencvIsolateOps {
  const OpencvIsolateOps._();

  static void _writeJpeg(String dstPath, cv.Mat mat, int quality) {
    final parent = File(dstPath).parent;
    if (!parent.existsSync()) parent.createSync(recursive: true);

    final params = cv.VecI32.fromList([cv.IMWRITE_JPEG_QUALITY, quality]);
    try {
      final ok = cv.imwrite(dstPath, mat, params: params);
      if (!ok) throw StateError('Failed to write image to $dstPath');
    } finally {
      params.dispose();
    }
  }

  static cv.Mat _downscaleIfNeeded(cv.Mat current, int maxSide) {
    final w = current.width;
    final h = current.height;
    final longest = math.max(w, h);
    if (longest <= maxSide) return current;

    final scale = maxSide / longest;
    final targetW = (w * scale).round();
    final targetH = (h * scale).round();
    final resized = cv.resize(current, (targetW, targetH), interpolation: cv.INTER_AREA);
    current.dispose();
    return resized;
  }

  static ImageSize importCapture(String srcPath, String dstPath, int maxSide, int quality) {
    final cv.Mat src = cv.imread(srcPath, flags: cv.IMREAD_COLOR);
    if (src.isEmpty) {
      src.dispose();
      throw ArgumentError('Failed to read image at $srcPath');
    }

    cv.Mat current = src;
    try {
      current = _downscaleIfNeeded(current, maxSide);
      _writeJpeg(dstPath, current, quality);
      return ImageSize(width: current.width, height: current.height);
    } finally {
      current.dispose();
    }
  }

  static String makePreview(String srcPath, String dstPath, int maxSide, int quality) {
    final cv.Mat src = cv.imread(srcPath, flags: cv.IMREAD_COLOR);
    if (src.isEmpty) {
      src.dispose();
      throw ArgumentError('Failed to read image at $srcPath');
    }

    cv.Mat current = src;
    try {
      current = _downscaleIfNeeded(current, maxSide);
      _writeJpeg(dstPath, current, quality);
      return dstPath;
    } finally {
      current.dispose();
    }
  }

  static String renderPage({
    required String srcPath,
    required Quad quad,
    required int rotation,
    required String dstPath,
    required int quality,
  }) {
    final cv.Mat src = cv.imread(srcPath, flags: cv.IMREAD_COLOR);
    if (src.isEmpty) {
      src.dispose();
      throw ArgumentError('Failed to read image at $srcPath');
    }

    cv.VecPoint2f? srcPts;
    cv.VecPoint2f? dstPts;
    cv.Mat? transform;
    cv.Mat? warped;
    cv.Mat? rotated;

    try {
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

      srcPts = cv.VecPoint2f.fromList([
        cv.Point2f(tl.dx, tl.dy),
        cv.Point2f(tr.dx, tr.dy),
        cv.Point2f(br.dx, br.dy),
        cv.Point2f(bl.dx, bl.dy),
      ]);
      dstPts = cv.VecPoint2f.fromList([
        cv.Point2f(0, 0),
        cv.Point2f(outW.toDouble(), 0),
        cv.Point2f(outW.toDouble(), outH.toDouble()),
        cv.Point2f(0, outH.toDouble()),
      ]);

      transform = cv.getPerspectiveTransform2f(srcPts, dstPts);
      warped = cv.warpPerspective(src, transform, (outW, outH), flags: cv.INTER_LINEAR);

      final rot = (rotation % 360 + 360) % 360;
      switch (rot) {
        case 0:
          rotated = warped;
        case 90:
          rotated = cv.rotate(warped, cv.ROTATE_90_CLOCKWISE);
        case 180:
          rotated = cv.rotate(warped, cv.ROTATE_180);
        case 270:
          rotated = cv.rotate(warped, cv.ROTATE_90_COUNTERCLOCKWISE);
        default:
          throw ArgumentError.value(rotation, 'rotation', 'Must be 0, 90, 180, or 270');
      }

      _writeJpeg(dstPath, rotated, quality);
      return dstPath;
    } finally {
      src.dispose();
      srcPts?.dispose();
      dstPts?.dispose();
      transform?.dispose();
      if (rotated != null && rotated != warped) rotated.dispose();
      warped?.dispose();
    }
  }
}
