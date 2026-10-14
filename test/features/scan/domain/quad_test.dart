import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/features/scan/domain/quad.dart';

void main() {
  group('Quad', () {
    test('ordering of shuffled points orders them TL, TR, BR, BL', () {
      const tl = Offset(0.12, 0.15);
      const tr = Offset(0.88, 0.10);
      const br = Offset(0.85, 0.90);
      const bl = Offset(0.10, 0.85);

      final shuffled = [br, tl, bl, tr];
      final quad = Quad.fromUnordered(shuffled);

      expect(quad.topLeft, equals(tl));
      expect(quad.topRight, equals(tr));
      expect(quad.bottomRight, equals(br));
      expect(quad.bottomLeft, equals(bl));
    });

    test('validity accepts normal convex quad and rejects concave, tiny, self-intersecting', () {
      final valid = Quad.defaultInset();
      expect(valid.isValid, isTrue);

      const tiny = Quad(
        topLeft: Offset(0.1, 0.1),
        topRight: Offset(0.2, 0.1),
        bottomRight: Offset(0.2, 0.2),
        bottomLeft: Offset(0.1, 0.2),
      );
      expect(tiny.isValid, isFalse, reason: 'Area < 10% must be rejected');

      const concave = Quad(
        topLeft: Offset(0.1, 0.1),
        topRight: Offset(0.9, 0.1),
        bottomRight: Offset(0.4, 0.4),
        bottomLeft: Offset(0.1, 0.9),
      );
      expect(concave.isValid, isFalse, reason: 'Concave quad must be rejected');

      const selfIntersecting = Quad(
        topLeft: Offset(0.1, 0.1),
        topRight: Offset(0.9, 0.9),
        bottomRight: Offset(0.9, 0.1),
        bottomLeft: Offset(0.1, 0.9),
      );
      expect(selfIntersecting.isValid, isFalse, reason: 'Bowtie quad must be rejected');

      const outsideBounds = Quad(
        topLeft: Offset(-0.1, 0.1),
        topRight: Offset(0.9, 0.1),
        bottomRight: Offset(0.9, 0.9),
        bottomLeft: Offset(0.1, 0.9),
      );
      expect(outsideBounds.isValid, isFalse, reason: 'Points outside 0..1 must be rejected');
    });

    test('json round trip preserves normalized coordinates', () {
      final original = Quad.defaultInset(0.08);
      final json = original.toJson();
      final restored = Quad.fromJson(json);

      expect(restored, equals(original));
      expect(restored.topLeft, equals(original.topLeft));
      expect(restored.bottomRight, equals(original.bottomRight));
    });

    test('rotated90 four times returns the original quad', () {
      const quad = Quad(
        topLeft: Offset(0.10, 0.15),
        topRight: Offset(0.85, 0.12),
        bottomRight: Offset(0.90, 0.82),
        bottomLeft: Offset(0.15, 0.88),
      );

      final r1 = quad.rotated90();
      final r2 = r1.rotated90();
      final r3 = r2.rotated90();
      final r4 = r3.rotated90();

      expect(r4, equals(quad));
    });

    test('toPixels converts normalized coordinates to given pixel Size', () {
      final quad = Quad.defaultInset(0.1);
      final pixelQuad = quad.toPixels(const Size(1000, 2000));

      expect(pixelQuad.topLeft, equals(const Offset(100, 200)));
      expect(pixelQuad.topRight, equals(const Offset(900, 200)));
      expect(pixelQuad.bottomRight, equals(const Offset(900, 1800)));
      expect(pixelQuad.bottomLeft, equals(const Offset(100, 1800)));
    });
  });
}
