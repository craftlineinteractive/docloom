import 'dart:isolate';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_config.dart';
import '../domain/image_engine.dart';
import '../domain/quad.dart';
import 'opencv_isolate_ops.dart';

final engineProvider = Provider<ImageEngine>((ref) {
  return const OpencvImageEngine();
});

class OpencvImageEngine implements ImageEngine {
  const OpencvImageEngine();

  @override
  Future<ImageSize> importCapture({
    required String srcPath,
    required String dstPath,
  }) {
    return Isolate.run(() {
      return OpencvIsolateOps.importCapture(
        srcPath,
        dstPath,
        AppConfig.scanMaxSide,
        AppConfig.jpegQuality,
      );
    });
  }

  @override
  Future<String> makePreview({
    required String srcPath,
    required String dstPath,
  }) {
    return Isolate.run(() {
      return OpencvIsolateOps.makePreview(
        srcPath,
        dstPath,
        AppConfig.previewMaxSide,
        AppConfig.jpegQuality,
      );
    });
  }

  @override
  Future<String> renderPage({
    required String srcPath,
    required Quad quad,
    required int rotation,
    required String filterId,
    required String dstPath,
  }) {
    if (filterId != 'original') {
      throw UnsupportedError('filters arrive in 4E');
    }

    return Isolate.run(() {
      return OpencvIsolateOps.renderPage(
        srcPath: srcPath,
        quad: quad,
        rotation: rotation,
        dstPath: dstPath,
        quality: AppConfig.jpegQuality,
      );
    });
  }
}
