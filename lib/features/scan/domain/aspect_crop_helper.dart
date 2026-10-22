import 'dart:math' as math;
import 'dart:ui';
import 'quad.dart';

class AspectCropHelper {
  const AspectCropHelper._();

  static Rect initialRect({required double targetAR, required double imageAR}) {
    final normAR = targetAR / imageAR;
    double w, h;
    if (normAR <= 1.0) {
      h = 0.8;
      w = (h * normAR).clamp(0.1, 0.95);
      h = w / normAR;
    } else {
      w = 0.8;
      h = (w / normAR).clamp(0.1, 0.95);
      w = h * normAR;
    }
    final l = (1.0 - w) / 2;
    final t = (1.0 - h) / 2;
    return Rect.fromLTWH(l, t, w, h);
  }

  static Quad rectToQuad(Rect r) => Quad(
        topLeft: r.topLeft,
        topRight: r.topRight,
        bottomRight: r.bottomRight,
        bottomLeft: r.bottomLeft,
      );

  static Rect quadToRect(Quad q) => Rect.fromLTRB(
        math.min(q.topLeft.dx, q.bottomLeft.dx),
        math.min(q.topLeft.dy, q.topRight.dy),
        math.max(q.topRight.dx, q.bottomRight.dx),
        math.max(q.bottomLeft.dy, q.bottomRight.dy),
      );

  static Rect moveRect(Rect current, double dx, double dy) {
    var l = current.left + dx;
    var t = current.top + dy;
    if (l < 0) l = 0;
    if (t < 0) t = 0;
    if (l + current.width > 1.0) l = 1.0 - current.width;
    if (t + current.height > 1.0) t = 1.0 - current.height;
    return Rect.fromLTWH(l, t, current.width, current.height);
  }

  static Rect resizeCorner({
    required Rect current,
    required int corner, // 0: TL, 1: TR, 2: BR, 3: BL
    required Offset newPoint,
    required double normAR,
  }) {
    switch (corner) {
      case 2: // Bottom-Right, anchor TL
        var w = (newPoint.dx - current.left).clamp(0.1, 1.0 - current.left);
        var h = w / normAR;
        if (current.top + h > 1.0) {
          h = 1.0 - current.top;
          w = h * normAR;
        }
        return Rect.fromLTWH(current.left, current.top, w, h);
      case 0: // Top-Left, anchor BR
        var w = (current.right - newPoint.dx).clamp(0.1, current.right);
        var h = w / normAR;
        if (current.bottom - h < 0) {
          h = current.bottom;
          w = h * normAR;
        }
        return Rect.fromLTWH(current.right - w, current.bottom - h, w, h);
      case 1: // Top-Right, anchor BL
        var w = (newPoint.dx - current.left).clamp(0.1, 1.0 - current.left);
        var h = w / normAR;
        if (current.bottom - h < 0) {
          h = current.bottom;
          w = h * normAR;
        }
        return Rect.fromLTWH(current.left, current.bottom - h, w, h);
      case 3: // Bottom-Left, anchor TR
      default:
        var w = (current.right - newPoint.dx).clamp(0.1, current.right);
        var h = w / normAR;
        if (current.top + h > 1.0) {
          h = 1.0 - current.top;
          w = h * normAR;
        }
        return Rect.fromLTWH(current.right - w, current.top, w, h);
    }
  }
}
