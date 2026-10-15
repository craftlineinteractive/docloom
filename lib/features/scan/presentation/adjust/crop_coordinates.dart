import 'dart:ui';
import '../../domain/quad.dart';

abstract final class CropCoordinates {
  static Rect computeImageRect({
    required Size boxSize,
    required double imageAspectRatio,
  }) {
    if (boxSize.width <= 0 || boxSize.height <= 0 || imageAspectRatio <= 0) {
      return Rect.zero;
    }

    final boxAspect = boxSize.width / boxSize.height;
    double renderWidth;
    double renderHeight;
    double offsetX;
    double offsetY;

    if (boxAspect > imageAspectRatio) {
      renderHeight = boxSize.height;
      renderWidth = boxSize.height * imageAspectRatio;
      offsetX = (boxSize.width - renderWidth) / 2.0;
      offsetY = 0.0;
    } else {
      renderWidth = boxSize.width;
      renderHeight = boxSize.width / imageAspectRatio;
      offsetX = 0.0;
      offsetY = (boxSize.height - renderHeight) / 2.0;
    }

    return Rect.fromLTWH(offsetX, offsetY, renderWidth, renderHeight);
  }

  static Offset widgetToNormalized({
    required Offset widgetPoint,
    required Size boxSize,
    required double imageAspectRatio,
    bool clamp = true,
  }) {
    final rect = computeImageRect(
      boxSize: boxSize,
      imageAspectRatio: imageAspectRatio,
    );
    if (rect.width <= 0 || rect.height <= 0) return Offset.zero;

    var nx = (widgetPoint.dx - rect.left) / rect.width;
    var ny = (widgetPoint.dy - rect.top) / rect.height;

    if (clamp) {
      nx = nx.clamp(0.0, 1.0);
      ny = ny.clamp(0.0, 1.0);
    }
    return Offset(nx, ny);
  }

  static Offset normalizedToWidget({
    required Offset normalizedPoint,
    required Size boxSize,
    required double imageAspectRatio,
  }) {
    final rect = computeImageRect(
      boxSize: boxSize,
      imageAspectRatio: imageAspectRatio,
    );
    return Offset(
      rect.left + (normalizedPoint.dx * rect.width),
      rect.top + (normalizedPoint.dy * rect.height),
    );
  }

  static Quad quadNormalizedToWidget({
    required Quad quad,
    required Size boxSize,
    required double imageAspectRatio,
  }) {
    return Quad(
      topLeft: normalizedToWidget(
        normalizedPoint: quad.topLeft,
        boxSize: boxSize,
        imageAspectRatio: imageAspectRatio,
      ),
      topRight: normalizedToWidget(
        normalizedPoint: quad.topRight,
        boxSize: boxSize,
        imageAspectRatio: imageAspectRatio,
      ),
      bottomRight: normalizedToWidget(
        normalizedPoint: quad.bottomRight,
        boxSize: boxSize,
        imageAspectRatio: imageAspectRatio,
      ),
      bottomLeft: normalizedToWidget(
        normalizedPoint: quad.bottomLeft,
        boxSize: boxSize,
        imageAspectRatio: imageAspectRatio,
      ),
    );
  }
}
