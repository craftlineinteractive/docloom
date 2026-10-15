import 'package:flutter/foundation.dart';
import 'quad.dart';

@immutable
class ImageSize {
  const ImageSize({required this.width, required this.height});

  final int width;
  final int height;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageSize &&
          runtimeType == other.runtimeType &&
          width == other.width &&
          height == other.height;

  @override
  int get hashCode => Object.hash(width, height);

  @override
  String toString() => 'ImageSize(width: $width, height: $height)';
}

abstract interface class ImageEngine {
  Future<ImageSize> importCapture({
    required String srcPath,
    required String dstPath,
  });

  Future<String> makePreview({
    required String srcPath,
    required String dstPath,
  });

  Future<String> renderPage({
    required String srcPath,
    required Quad quad,
    required int rotation,
    required String filterId,
    required String dstPath,
  });

  Future<Uint8List> renderPreview({
    required String previewPath,
    required Quad quad,
    required int rotation,
    required String filterId,
    int? maxSide,
  });
}
