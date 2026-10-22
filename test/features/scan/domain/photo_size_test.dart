import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/features/scan/domain/photo_size.dart';
import 'package:docloom/features/scan/domain/photo_size_presets.dart';

void main() {
  group('PhotoSize pixel calculations', () {
    test('inches: 2x2 in @ 600dpi = 1200x1200 px', () {
      final p = PhotoSize.calculatePixels(
        width: 2.0,
        height: 2.0,
        unit: PhotoUnit.inches,
        dpi: 600,
      );
      expect(p.width, equals(1200));
      expect(p.height, equals(1200));
    });

    test('mm: 35x45 mm @ 300dpi = 413x531 px', () {
      final p = PhotoSize.calculatePixels(
        width: 35.0,
        height: 45.0,
        unit: PhotoUnit.mm,
        dpi: 300,
      );
      // 35 / 25.4 * 300 = 413.38 -> 413
      // 45 / 25.4 * 300 = 531.49 -> 531
      expect(p.width, equals(413));
      expect(p.height, equals(531));
    });

    test('cm: 2x2.5 cm @ 450dpi = 354x443 px', () {
      final p = PhotoSize.calculatePixels(
        width: 2.0,
        height: 2.5,
        unit: PhotoUnit.cm,
        dpi: 450,
      );
      // 2 / 2.54 * 450 = 354.33 -> 354
      // 2.5 / 2.54 * 450 = 442.91 -> 443
      expect(p.width, equals(354));
      expect(p.height, equals(443));
    });

    test('px: 600x600 px @ 1 = 600x600 px', () {
      final p = PhotoSize.calculatePixels(
        width: 600.0,
        height: 600.0,
        unit: PhotoUnit.px,
        dpi: 1,
      );
      expect(p.width, equals(600));
      expect(p.height, equals(600));
    });

    test('all 6 presets produce positive pixel dimensions', () {
      expect(PhotoSizePresets.defaults.length, equals(6));
      for (final preset in PhotoSizePresets.defaults) {
        final pixels = preset.pixelSize;
        expect(pixels.width, greaterThan(0));
        expect(pixels.height, greaterThan(0));
        expect(preset.title.isNotEmpty, isTrue);
        expect(preset.subtitle.isNotEmpty, isTrue);
      }
    });

    test('json serialization roundtrip', () {
      const original = PhotoSize(
        id: 'test_id',
        width: 50,
        height: 50,
        unit: PhotoUnit.mm,
        dpi: 300,
      );
      final json = original.toJson();
      final restored = PhotoSize.fromJson(json);
      expect(restored.id, equals(original.id));
      expect(restored.width, equals(original.width));
      expect(restored.height, equals(original.height));
      expect(restored.unit, equals(original.unit));
      expect(restored.dpi, equals(original.dpi));
    });
  });
}
