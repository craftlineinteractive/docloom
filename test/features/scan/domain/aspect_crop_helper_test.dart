import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/features/scan/domain/aspect_crop_helper.dart';

void main() {
  group('AspectCropHelper', () {
    test('initialRect maintains aspect ratio within bounds', () {
      final rect = AspectCropHelper.initialRect(targetAR: 1.0, imageAR: 0.75);
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(1));
      expect(rect.top, greaterThanOrEqualTo(0));
      expect(rect.bottom, lessThanOrEqualTo(1));

      final physicalAR = (rect.width / rect.height) * 0.75;
      expect((physicalAR - 1.0).abs(), lessThan(0.01));
    });

    test('rectToQuad and quadToRect roundtrip', () {
      const rect = Rect.fromLTWH(0.1, 0.2, 0.5, 0.6);
      final quad = AspectCropHelper.rectToQuad(rect);
      expect(quad.topLeft, equals(const Offset(0.1, 0.2)));
      expect(quad.topRight, equals(const Offset(0.6, 0.2)));
      expect(quad.bottomRight, equals(const Offset(0.6, 0.8)));
      expect(quad.bottomLeft, equals(const Offset(0.1, 0.8)));

      final roundtrip = AspectCropHelper.quadToRect(quad);
      expect(roundtrip, equals(rect));
    });

    test('moveRect clamps to image boundaries', () {
      const rect = Rect.fromLTWH(0.2, 0.2, 0.4, 0.4);
      final movedRight = AspectCropHelper.moveRect(rect, 0.5, 0.0);
      expect(movedRight.right, closeTo(1.0, 0.0001));
      expect(movedRight.left, closeTo(0.6, 0.0001));

      final movedLeft = AspectCropHelper.moveRect(rect, -0.5, 0.0);
      expect(movedLeft.left, closeTo(0.0, 0.0001));
      expect(movedLeft.right, closeTo(0.4, 0.0001));
    });

    test('resizeCorner maintains normAR on bottom-right drag', () {
      const rect = Rect.fromLTWH(0.1, 0.1, 0.4, 0.3);
      const normAR = 0.4 / 0.3;
      final resized = AspectCropHelper.resizeCorner(
        current: rect,
        corner: 2,
        newPoint: const Offset(0.7, 0.55),
        normAR: normAR,
      );
      expect(resized.left, closeTo(0.1, 0.0001));
      expect(resized.top, closeTo(0.1, 0.0001));
      final actualNormAR = resized.width / resized.height;
      expect((actualNormAR - normAR).abs(), lessThan(0.01));
    });
  });
}
