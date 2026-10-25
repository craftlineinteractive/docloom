import 'dart:ui';
import 'package:flutter_better_scanner/flutter_better_scanner.dart' as p;
import 'quad.dart';

extension QuadPackageAdapter on Quad {
  Quad clamp01() => Quad(
        topLeft: Offset(
          topLeft.dx.clamp(0.0, 1.0),
          topLeft.dy.clamp(0.0, 1.0),
        ),
        topRight: Offset(
          topRight.dx.clamp(0.0, 1.0),
          topRight.dy.clamp(0.0, 1.0),
        ),
        bottomRight: Offset(
          bottomRight.dx.clamp(0.0, 1.0),
          bottomRight.dy.clamp(0.0, 1.0),
        ),
        bottomLeft: Offset(
          bottomLeft.dx.clamp(0.0, 1.0),
          bottomLeft.dy.clamp(0.0, 1.0),
        ),
      );

  p.Quad toPackageQuad() {
    final c = clamp01();
    return p.Quad(c.topLeft, c.topRight, c.bottomRight, c.bottomLeft);
  }

  static Quad fromPackageQuad(p.Quad q) => Quad(
        topLeft: Offset(
          q.tl.dx.clamp(0.0, 1.0),
          q.tl.dy.clamp(0.0, 1.0),
        ),
        topRight: Offset(
          q.tr.dx.clamp(0.0, 1.0),
          q.tr.dy.clamp(0.0, 1.0),
        ),
        bottomRight: Offset(
          q.br.dx.clamp(0.0, 1.0),
          q.br.dy.clamp(0.0, 1.0),
        ),
        bottomLeft: Offset(
          q.bl.dx.clamp(0.0, 1.0),
          q.bl.dy.clamp(0.0, 1.0),
        ),
      );
}

