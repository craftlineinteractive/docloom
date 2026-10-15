import 'dart:ui';
import '../../../../core/theme/app_sizes.dart';
import '../../domain/quad.dart';

abstract final class CropDragHelper {
  static int? findClosestCorner({
    required Quad pixelQuad,
    required Offset touchPoint,
    double hitRadius = AppSizes.cropHandleHitArea / 2,
  }) {
    final points = pixelQuad.points;
    int? closest;
    var minDist = double.infinity;
    for (var i = 0; i < points.length; i++) {
      final dist = (points[i] - touchPoint).distance;
      if (dist <= hitRadius && dist < minDist) {
        minDist = dist;
        closest = i;
      }
    }
    return closest;
  }

  static Quad updateCorner({
    required Quad current,
    required int corner,
    required Offset newPoint,
  }) {
    return switch (corner) {
      0 => Quad(topLeft: newPoint, topRight: current.tr, bottomRight: current.br, bottomLeft: current.bl),
      1 => Quad(topLeft: current.tl, topRight: newPoint, bottomRight: current.br, bottomLeft: current.bl),
      2 => Quad(topLeft: current.tl, topRight: current.tr, bottomRight: newPoint, bottomLeft: current.bl),
      3 => Quad(topLeft: current.tl, topRight: current.tr, bottomRight: current.br, bottomLeft: newPoint),
      _ => current,
    };
  }
}
