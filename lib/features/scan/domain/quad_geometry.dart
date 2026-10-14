import 'dart:ui';
import 'quad.dart';

class QuadGeometry {
  const QuadGeometry._();

  static List<Offset> orderPoints(List<Offset> points) {
    if (points.length != 4) {
      throw ArgumentError.value(points.length, 'points', 'Exactly 4 points are required');
    }

    Offset? tl;
    Offset? br;
    Offset? tr;
    Offset? bl;

    var minSum = double.infinity;
    var maxSum = -double.infinity;
    var minDiff = double.infinity;
    var maxDiff = -double.infinity;

    for (final p in points) {
      final sum = p.dx + p.dy;
      final diff = p.dy - p.dx;

      if (sum < minSum) {
        minSum = sum;
        tl = p;
      }
      if (sum > maxSum) {
        maxSum = sum;
        br = p;
      }
      if (diff < minDiff) {
        minDiff = diff;
        tr = p;
      }
      if (diff > maxDiff) {
        maxDiff = diff;
        bl = p;
      }
    }

    return [tl!, tr!, br!, bl!];
  }

  static bool isValid(List<Offset> points) {
    for (final p in points) {
      if (p.dx < 0.0 || p.dx > 1.0 || p.dy < 0.0 || p.dy > 1.0) {
        return false;
      }
    }

    final signs = <bool>[];
    for (var i = 0; i < 4; i++) {
      final p1 = points[i];
      final p2 = points[(i + 1) % 4];
      final p3 = points[(i + 2) % 4];

      final v1x = p2.dx - p1.dx;
      final v1y = p2.dy - p1.dy;
      final v2x = p3.dx - p2.dx;
      final v2y = p3.dy - p2.dy;

      final cross = (v1x * v2y) - (v1y * v2x);
      if (cross.abs() < 1e-7) return false;
      signs.add(cross > 0);
    }

    final isConvex = signs.every((s) => s) || signs.every((s) => !s);
    if (!isConvex) return false;

    var doubleArea = 0.0;
    for (var i = 0; i < 4; i++) {
      final p1 = points[i];
      final p2 = points[(i + 1) % 4];
      doubleArea += (p1.dx * p2.dy) - (p2.dx * p1.dy);
    }
    return (doubleArea.abs() / 2.0) >= 0.10;
  }

  static Quad rotate90(Quad quad) {
    Offset rot(Offset p) => Offset(1.0 - p.dy, p.dx);
    return Quad(
      topLeft: rot(quad.bottomLeft),
      topRight: rot(quad.topLeft),
      bottomRight: rot(quad.topRight),
      bottomLeft: rot(quad.bottomRight),
    );
  }
}
