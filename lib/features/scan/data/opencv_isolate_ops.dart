// Read dartcv4/lib/src/imgcodecs/imgcodecs.dart for imread, imwrite, and imencode
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import '../domain/image_engine.dart';
import '../domain/quad.dart';
import 'opencv_transform_ops.dart';

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
    required String filterId,
    required String dstPath,
    required int quality,
    int? targetWidth,
    int? targetHeight,
  }) {
    final cv.Mat src = cv.imread(srcPath, flags: cv.IMREAD_COLOR);
    if (src.isEmpty) {
      src.dispose();
      throw ArgumentError('Failed to read image at $srcPath');
    }
    try {
      final processed = OpencvTransformOps.warpRotateAndFilter(
        src: src,
        quad: quad,
        rotation: rotation,
        filterId: filterId,
        targetWidth: targetWidth,
        targetHeight: targetHeight,
      );
      try {
        _writeJpeg(dstPath, processed, quality);
        return dstPath;
      } finally {
        processed.dispose();
      }
    } finally {
      src.dispose();
    }
  }

  static Uint8List renderPreview({
    required String previewPath,
    required Quad quad,
    required int rotation,
    required String filterId,
    int? maxSide,
    required int quality,
  }) {
    final cv.Mat src = cv.imread(previewPath, flags: cv.IMREAD_COLOR);
    if (src.isEmpty) {
      src.dispose();
      throw ArgumentError('Failed to read image at $previewPath');
    }

    try {
      cv.Mat current = OpencvTransformOps.warpRotateAndFilter(
        src: src,
        quad: quad,
        rotation: rotation,
        filterId: filterId,
      );
      if (maxSide != null) {
        current = _downscaleIfNeeded(current, maxSide);
      }
      final params = cv.VecI32.fromList([cv.IMWRITE_JPEG_QUALITY, quality]);
      try {
        final (ok, bytes) = cv.imencode('.jpg', current, params: params);
        if (!ok) throw StateError('Failed to encode JPEG preview');
        return bytes;
      } finally {
        current.dispose();
        params.dispose();
      }
    } finally {
      src.dispose();
    }
  }
}
