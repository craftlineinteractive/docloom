import 'dart:isolate';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_config.dart';
import '../domain/image_engine.dart';
import '../domain/quad.dart';
import 'opencv_card_ops.dart';
import 'opencv_isolate_ops.dart';
import 'preview_lru_cache.dart';

final engineProvider = Provider<ImageEngine>((ref) => OpencvImageEngine());

class OpencvImageEngine implements ImageEngine {
  OpencvImageEngine({PreviewLruCache? cache}) : cache = cache ?? PreviewLruCache();

  final PreviewLruCache cache;

  @override
  Future<ImageSize> importCapture({required String srcPath, required String dstPath}) {
    return Isolate.run(() => OpencvIsolateOps.importCapture(
          srcPath,
          dstPath,
          AppConfig.scanMaxSide,
          AppConfig.jpegQuality,
        ));
  }

  @override
  Future<String> makePreview({required String srcPath, required String dstPath}) {
    return Isolate.run(() => OpencvIsolateOps.makePreview(
          srcPath,
          dstPath,
          AppConfig.previewMaxSide,
          AppConfig.jpegQuality,
        ));
  }

  static void _validateFilterId(String filterId) {
    const valid = {'original', 'grayscale', 'black_white', 'auto_enhance', 'vivid_light'};
    if (!valid.contains(filterId)) {
      throw UnsupportedError('Unsupported filterId: $filterId');
    }
  }

  @override
  Future<String> renderPage({
    required String srcPath,
    required Quad quad,
    required int rotation,
    required String filterId,
    required String dstPath,
    int? targetWidth,
    int? targetHeight,
  }) {
    _validateFilterId(filterId);
    return Isolate.run(() => OpencvIsolateOps.renderPage(
          srcPath: srcPath,
          quad: quad,
          rotation: rotation,
          filterId: filterId,
          dstPath: dstPath,
          quality: AppConfig.jpegQuality,
          targetWidth: targetWidth,
          targetHeight: targetHeight,
        ));
  }

  @override
  Future<Uint8List> renderPreview({
    required String previewPath,
    required Quad quad,
    required int rotation,
    required String filterId,
    int? maxSide,
  }) async {
    _validateFilterId(filterId);
    final key = PreviewCacheKey(
      path: previewPath,
      quadHash: quad.hashCode,
      rotation: rotation,
      filterId: filterId,
      maxSide: maxSide,
    );
    final cached = cache.get(key);
    if (cached != null) return cached;

    final bytes = await Isolate.run(() => OpencvIsolateOps.renderPreview(
          previewPath: previewPath,
          quad: quad,
          rotation: rotation,
          filterId: filterId,
          maxSide: maxSide,
          quality: AppConfig.jpegQuality,
        ));

    cache.put(key, bytes);
    return bytes;
  }

  @override
  Future<String> composeCardPage({
    required String frontPath,
    String? backPath,
    required String dstPath,
  }) {
    return Isolate.run(() => OpencvCardOps.composeCardPage(
          frontPath: frontPath,
          backPath: backPath,
          dstPath: dstPath,
          quality: AppConfig.jpegQuality,
        ));
  }
}
