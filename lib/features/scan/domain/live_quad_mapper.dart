import 'dart:math' as math;
import 'dart:ui';
import 'quad.dart';

abstract final class LiveQuadMapper {
  /// Maps a live quad in preview normalized space [0..1] to the capture image's
  /// normalized space [0..1], taking into account aspect ratios and sensor rotation.
  static Quad map({
    required Quad liveQuad,
    required double previewAspectRatio,
    required double captureWidth,
    required double captureHeight,
  }) {
    final capAspect = captureWidth / captureHeight;
    final isCaptureLandscape = capAspect > 1.0;
    final isPreviewPortrait = previewAspectRatio < 1.0;

    final targetCapAspect = (isCaptureLandscape && isPreviewPortrait)
        ? (1.0 / capAspect)
        : capAspect;

    final double scaleX, scaleY, offsetX, offsetY;
    if (previewAspectRatio < targetCapAspect) {
      scaleX = previewAspectRatio / targetCapAspect;
      scaleY = 1.0;
      offsetX = (1.0 - scaleX) / 2.0;
      offsetY = 0.0;
    } else if (previewAspectRatio > targetCapAspect) {
      scaleX = 1.0;
      scaleY = targetCapAspect / previewAspectRatio;
      offsetX = 0.0;
      offsetY = (1.0 - scaleY) / 2.0;
    } else {
      scaleX = 1.0;
      scaleY = 1.0;
      offsetX = 0.0;
      offsetY = 0.0;
    }

    Offset mapPoint(Offset p) {
      final xComp = (offsetX + p.dx * scaleX).clamp(0.0, 1.0);
      final yComp = (offsetY + p.dy * scaleY).clamp(0.0, 1.0);
      if (isCaptureLandscape && isPreviewPortrait) {
        return Offset(yComp, (1.0 - xComp).clamp(0.0, 1.0));
      }
      return Offset(xComp, yComp);
    }

    return Quad.fromUnordered(liveQuad.points.map(mapPoint).toList());
  }

  static Future<Quad> resolveInitialQuad({
    required Quad? liveQuad,
    required DateTime? liveQuadTime,
    required double previewAspect,
    required double captureWidth,
    required double captureHeight,
    required String previewPath,
    required Future<Quad?> Function(String path) detectFromFile,
  }) async {
    if (liveQuad != null && liveQuadTime != null) {
      final age = DateTime.now().difference(liveQuadTime);
      if (age >= Duration.zero && age <= const Duration(milliseconds: 1500)) {
        return map(
          liveQuad: liveQuad,
          previewAspectRatio: previewAspect,
          captureWidth: captureWidth,
          captureHeight: captureHeight,
        );
      }
    }
    try {
      final detected = await detectFromFile(previewPath);
      if (detected != null) return detected;
    } catch (_) {}
    return Quad.defaultInset();
  }

  /// Calculates the maximum corner distance between two quads, normalized to image diagonal.
  static double maxCornerErrorNormalized(Quad a, Quad b) {
    const diagonal = 1.4142135623730951;
    final d0 = (a.topLeft - b.topLeft).distance;
    final d1 = (a.topRight - b.topRight).distance;
    final d2 = (a.bottomRight - b.bottomRight).distance;
    final d3 = (a.bottomLeft - b.bottomLeft).distance;
    return math.max(math.max(d0, d1), math.max(d2, d3)) / diagonal;
  }
}
