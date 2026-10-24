import 'dart:math' as math;
import 'dart:ui';
import 'quad.dart';

abstract final class PerspectiveAspectHelper {
  /// Computes the unwarped output dimensions (width, height) using Zhang & He
  /// perspective aspect ratio recovery with principal point at image center.
  static Size recoverOutputDimensions({
    required Quad pixelQuad,
    required Size imageSize,
  }) {
    final tl = pixelQuad.topLeft;
    final tr = pixelQuad.topRight;
    final br = pixelQuad.bottomRight;
    final bl = pixelQuad.bottomLeft;

    double dist(Offset a, Offset b) => math.sqrt(
          (a.dx - b.dx) * (a.dx - b.dx) + (a.dy - b.dy) * (a.dy - b.dy),
        );

    final edgeW = math.max(dist(tl, tr), dist(bl, br));
    final edgeH = math.max(dist(tl, bl), dist(tr, br));
    if (edgeW <= 0 || edgeH <= 0) return const Size(1, 1);

    final u0 = imageSize.width / 2.0;
    final v0 = imageSize.height / 2.0;

    // Relative to principal point at center
    final m1x = tl.dx - u0;
    final m1y = tl.dy - v0;
    final m2x = tr.dx - u0;
    final m2y = tr.dy - v0;
    final m3x = bl.dx - u0;
    final m3y = bl.dy - v0;
    final m4x = br.dx - u0;
    final m4y = br.dy - v0;

    final denomK2 = (m2y - m4y) * m3x - (m2x - m4x) * m3y + m2x * m4y - m2y * m4x;
    final denomK3 = (m3y - m4y) * m2x - (m3x - m4x) * m2y + m3x * m4y - m3y * m4x;

    double? whRatio;

    // Check if general Zhang & He formulation is well-conditioned
    if (denomK2.abs() >= 1e-6 && denomK3.abs() >= 1e-6) {
      final k2 = ((m1y - m4y) * m3x - (m1x - m4x) * m3y + m1x * m4y - m1y * m4x) / denomK2;
      final k3 = ((m1y - m4y) * m2x - (m1x - m4x) * m2y + m1x * m4y - m1y * m4x) / denomK3;

      final denomF = (k3 - 1.0) * (k2 - 1.0);
      if (denomF.abs() >= 1e-4) {
        final fSquared = -((k3 * m3y - m1y) * (k2 * m2y - m1y) +
                (k3 * m3x - m1x) * (k2 * m2x - m1x)) /
            denomF;

        if (fSquared > 0 && !fSquared.isNaN && !fSquared.isInfinite) {
          final numW = math.pow(k2 - 1.0, 2) +
              (math.pow(k2 * m2y - m1y, 2) + math.pow(k2 * m2x - m1x, 2)) / fSquared;
          final numH = math.pow(k3 - 1.0, 2) +
              (math.pow(k3 * m3y - m1y, 2) + math.pow(k3 * m3x - m1x, 2)) / fSquared;

          if (numW > 0 && numH > 0) {
            whRatio = math.sqrt(numW / numH);
          }
        }
      }
    }

    // Single-axis perspective fallback (e.g. horizontal tilt with parallel top/bottom)
    if (whRatio == null || whRatio.isNaN || whRatio <= 0 || whRatio.isInfinite) {
      final wTop = dist(tl, tr);
      final wBottom = dist(bl, br);
      final hLeft = dist(tl, bl);
      final hRight = dist(tr, br);

      // Standard smartphone camera FOV focal length: ~1.0 * max(w, h)
      final f = math.max(imageSize.width, imageSize.height) * 1.0;

      if ((wTop - wBottom).abs() > 2.0 && wTop > 0 && wBottom > 0) {
        final dy = (m3y / wBottom) - (m1y / wTop);
        final dz = f * ((1.0 / wBottom) - (1.0 / wTop));
        final recH = math.sqrt(dy * dy + dz * dz);
        if (recH > 0 && !recH.isNaN) whRatio = 1.0 / recH;
      } else if ((hLeft - hRight).abs() > 2.0 && hLeft > 0 && hRight > 0) {
        final dx = (m2x / hRight) - (m1x / hLeft);
        final dz = f * ((1.0 / hRight) - (1.0 / hLeft));
        final recW = math.sqrt(dx * dx + dz * dz);
        if (recW > 0 && !recW.isNaN) whRatio = recW;
      }
    }

    final rawAspect = edgeW / edgeH;
    final targetWh = (whRatio != null && whRatio > 0 && !whRatio.isNaN)
        ? whRatio.clamp(0.25, 4.0)
        : rawAspect;

    double finalW;
    double finalH;
    if (targetWh >= 1.0) {
      finalW = math.max(edgeW, edgeH * targetWh);
      finalH = finalW / targetWh;
    } else {
      finalH = math.max(edgeH, edgeW / targetWh);
      finalW = finalH * targetWh;
    }

    return Size(math.max(1, finalW.roundToDouble()), math.max(1, finalH.roundToDouble()));
  }
}
