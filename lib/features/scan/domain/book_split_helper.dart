import 'dart:ui';
import 'quad.dart';

class BookSplitResult {
  const BookSplitResult({required this.left, required this.right});

  final Quad left;
  final Quad right;
}

class BookSplitHelper {
  const BookSplitHelper._();

  static BookSplitResult splitQuad(Quad spreadQuad, [double splitRatio = 0.5]) {
    final t = splitRatio.clamp(0.05, 0.95);
    final topSplit = Offset(
      spreadQuad.topLeft.dx + (spreadQuad.topRight.dx - spreadQuad.topLeft.dx) * t,
      spreadQuad.topLeft.dy + (spreadQuad.topRight.dy - spreadQuad.topLeft.dy) * t,
    );
    final bottomSplit = Offset(
      spreadQuad.bottomLeft.dx + (spreadQuad.bottomRight.dx - spreadQuad.bottomLeft.dx) * t,
      spreadQuad.bottomLeft.dy + (spreadQuad.bottomRight.dy - spreadQuad.bottomLeft.dy) * t,
    );

    return BookSplitResult(
      left: Quad(
        topLeft: spreadQuad.topLeft,
        topRight: topSplit,
        bottomRight: bottomSplit,
        bottomLeft: spreadQuad.bottomLeft,
      ),
      right: Quad(
        topLeft: topSplit,
        topRight: spreadQuad.topRight,
        bottomRight: spreadQuad.bottomRight,
        bottomLeft: bottomSplit,
      ),
    );
  }
}
