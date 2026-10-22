import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/features/scan/domain/book_split_helper.dart';
import 'package:docloom/features/scan/domain/quad.dart';

void main() {
  group('BookSplitHelper', () {
    test('splitQuad at 0.5 divides unit Quad into left and right halves', () {
      final unit = Quad.unit();
      final result = BookSplitHelper.splitQuad(unit, 0.5);

      expect(result.left.topLeft, equals(const Offset(0.0, 0.0)));
      expect(result.left.topRight, equals(const Offset(0.5, 0.0)));
      expect(result.left.bottomRight, equals(const Offset(0.5, 1.0)));
      expect(result.left.bottomLeft, equals(const Offset(0.0, 1.0)));

      expect(result.right.topLeft, equals(const Offset(0.5, 0.0)));
      expect(result.right.topRight, equals(const Offset(1.0, 0.0)));
      expect(result.right.bottomRight, equals(const Offset(1.0, 1.0)));
      expect(result.right.bottomLeft, equals(const Offset(0.5, 1.0)));

      expect(result.left.isValid, isTrue);
      expect(result.right.isValid, isTrue);
    });

    test('splitQuad works on perspective quad with non-axis aligned points', () {
      const quad = Quad(
        topLeft: Offset(0.1, 0.1),
        topRight: Offset(0.9, 0.2),
        bottomRight: Offset(0.8, 0.9),
        bottomLeft: Offset(0.2, 0.8),
      );
      final result = BookSplitHelper.splitQuad(quad, 0.5);

      // Top split = (0.1 + 0.9)/2, (0.1 + 0.2)/2 = (0.5, 0.15)
      expect(result.left.topRight.dx, closeTo(0.5, 0.001));
      expect(result.left.topRight.dy, closeTo(0.15, 0.001));

      // Bottom split = (0.2 + 0.8)/2, (0.8 + 0.9)/2 = (0.5, 0.85)
      expect(result.left.bottomRight.dx, closeTo(0.5, 0.001));
      expect(result.left.bottomRight.dy, closeTo(0.85, 0.001));

      expect(result.right.topLeft, equals(result.left.topRight));
      expect(result.right.bottomLeft, equals(result.left.bottomRight));

      expect(result.left.isValid, isTrue);
      expect(result.right.isValid, isTrue);
    });
  });
}
