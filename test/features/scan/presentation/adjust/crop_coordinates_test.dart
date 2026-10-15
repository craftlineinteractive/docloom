import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/features/scan/domain/quad.dart';
import 'package:docloom/features/scan/presentation/adjust/crop_coordinates.dart';

void main() {
  group('CropCoordinates', () {
    test('Tall image letterboxed horizontally (pillarbox)', () {
      const boxSize = Size(400, 400);
      const aspect = 0.5; // width = 200, height = 400

      final rect = CropCoordinates.computeImageRect(
        boxSize: boxSize,
        imageAspectRatio: aspect,
      );
      expect(rect, equals(const Rect.fromLTWH(100, 0, 200, 400)));

      expect(
        CropCoordinates.widgetToNormalized(
          widgetPoint: const Offset(100, 0),
          boxSize: boxSize,
          imageAspectRatio: aspect,
        ),
        equals(Offset.zero),
      );
      expect(
        CropCoordinates.widgetToNormalized(
          widgetPoint: const Offset(200, 200),
          boxSize: boxSize,
          imageAspectRatio: aspect,
        ),
        equals(const Offset(0.5, 0.5)),
      );
      expect(
        CropCoordinates.widgetToNormalized(
          widgetPoint: const Offset(300, 400),
          boxSize: boxSize,
          imageAspectRatio: aspect,
        ),
        equals(const Offset(1.0, 1.0)),
      );
      // Clamping left beyond image bound
      expect(
        CropCoordinates.widgetToNormalized(
          widgetPoint: const Offset(50, 200),
          boxSize: boxSize,
          imageAspectRatio: aspect,
        ),
        equals(const Offset(0.0, 0.5)),
      );
    });

    test('Wide image letterboxed vertically', () {
      const boxSize = Size(400, 600);
      const aspect = 2.0; // width = 400, height = 200

      final rect = CropCoordinates.computeImageRect(
        boxSize: boxSize,
        imageAspectRatio: aspect,
      );
      expect(rect, equals(const Rect.fromLTWH(0, 200, 400, 200)));

      expect(
        CropCoordinates.widgetToNormalized(
          widgetPoint: const Offset(0, 200),
          boxSize: boxSize,
          imageAspectRatio: aspect,
        ),
        equals(Offset.zero),
      );
      expect(
        CropCoordinates.widgetToNormalized(
          widgetPoint: const Offset(200, 300),
          boxSize: boxSize,
          imageAspectRatio: aspect,
        ),
        equals(const Offset(0.5, 0.5)),
      );
      expect(
        CropCoordinates.widgetToNormalized(
          widgetPoint: const Offset(400, 400),
          boxSize: boxSize,
          imageAspectRatio: aspect,
        ),
        equals(const Offset(1.0, 1.0)),
      );
    });

    test('Square image in square box', () {
      const boxSize = Size(500, 500);
      const aspect = 1.0;

      final rect = CropCoordinates.computeImageRect(
        boxSize: boxSize,
        imageAspectRatio: aspect,
      );
      expect(rect, equals(const Rect.fromLTWH(0, 0, 500, 500)));

      expect(
        CropCoordinates.widgetToNormalized(
          widgetPoint: const Offset(250, 250),
          boxSize: boxSize,
          imageAspectRatio: aspect,
        ),
        equals(const Offset(0.5, 0.5)),
      );
    });

    test('Round-trip normalizedToWidget and widgetToNormalized', () {
      const boxSize = Size(360, 480);
      const aspect = 3 / 4;
      const initialNorm = Offset(0.35, 0.72);

      final widgetPoint = CropCoordinates.normalizedToWidget(
        normalizedPoint: initialNorm,
        boxSize: boxSize,
        imageAspectRatio: aspect,
      );
      final mappedNorm = CropCoordinates.widgetToNormalized(
        widgetPoint: widgetPoint,
        boxSize: boxSize,
        imageAspectRatio: aspect,
      );

      expect((mappedNorm.dx - initialNorm.dx).abs(), lessThan(1e-9));
      expect((mappedNorm.dy - initialNorm.dy).abs(), lessThan(1e-9));
    });

    test('quadNormalizedToWidget transforms all four corners', () {
      const boxSize = Size(300, 300);
      const aspect = 1.0;
      final quad = Quad.defaultInset(0.1);

      final pixelQuad = CropCoordinates.quadNormalizedToWidget(
        quad: quad,
        boxSize: boxSize,
        imageAspectRatio: aspect,
      );

      expect(pixelQuad.topLeft, equals(const Offset(30, 30)));
      expect(pixelQuad.topRight, equals(const Offset(270, 30)));
      expect(pixelQuad.bottomRight, equals(const Offset(270, 270)));
      expect(pixelQuad.bottomLeft, equals(const Offset(30, 270)));
    });
  });
}
