import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:docloom/core/storage/thumbnail_generator.dart';
import 'package:docloom/core/theme/app_sizes.dart';

Future<Uint8List> _createPng({int width = 800, int height = 600}) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  final paint = ui.Paint()..color = const ui.Color(0xFF00FF00);
  canvas.drawRect(ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()), paint);
  final picture = recorder.endRecording();
  final image = await picture.toImage(width, height);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  picture.dispose();
  return byteData!.buffer.asUint8List();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThumbnailGenerator', () {
    const generator = ThumbnailGenerator();

    test('generates resized PNG bytes with default thumbnailSource width', () async {
      final inputBytes = await _createPng(width: 800, height: 600);
      final thumbBytes = await generator.generate(sourceBytes: inputBytes);

      expect(thumbBytes.isNotEmpty, isTrue);

      final codec = await ui.instantiateImageCodec(thumbBytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      expect(image.width, equals(AppSizes.thumbnailSource));
      image.dispose();
      codec.dispose();
    });

    test('generateFromFile correctly reads file and outputs resized thumbnail', () async {
      final tempDir = await Directory.systemTemp.createTemp('thumb_test_');
      try {
        final file = File(p.join(tempDir.path, 'source.png'));
        final inputBytes = await _createPng(width: 600, height: 400);
        await file.writeAsBytes(inputBytes);

        final thumbBytes = await generator.generateFromFile(file);
        expect(thumbBytes.isNotEmpty, isTrue);

        final codec = await ui.instantiateImageCodec(thumbBytes);
        final frame = await codec.getNextFrame();
        final image = frame.image;

        expect(image.width, equals(AppSizes.thumbnailSource));
        image.dispose();
        codec.dispose();
      } finally {
        if (await tempDir.exists()) await tempDir.delete(recursive: true);
      }
    });
  });
}
