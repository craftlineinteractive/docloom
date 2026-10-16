import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import '../theme/app_sizes.dart';

class ThumbnailGenerator {
  const ThumbnailGenerator();

  Future<Uint8List> generate({
    required Uint8List sourceBytes,
    int targetDimension = AppSizes.thumbnailSource,
  }) async {
    final codec = await ui.instantiateImageCodec(
      sourceBytes,
      targetWidth: targetDimension,
    );
    try {
      final frame = await codec.getNextFrame();
      final image = frame.image;
      try {
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData == null) {
          throw StateError('Failed to encode thumbnail image to PNG');
        }
        return byteData.buffer.asUint8List();
      } finally {
        image.dispose();
      }
    } finally {
      codec.dispose();
    }
  }

  Future<Uint8List> generateFromFile(
    File sourceFile, {
    int targetDimension = AppSizes.thumbnailSource,
  }) async {
    final bytes = await sourceFile.readAsBytes();
    return generate(sourceBytes: bytes, targetDimension: targetDimension);
  }
}
