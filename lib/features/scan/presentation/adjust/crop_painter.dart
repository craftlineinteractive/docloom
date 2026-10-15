import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../domain/quad.dart';

class CropPainter extends CustomPainter {
  const CropPainter({
    required this.quad,
    required this.imageRect,
    this.activeCorner,
  });

  final Quad quad;
  final Rect imageRect;
  final int? activeCorner;

  @override
  void paint(Canvas canvas, Size size) {
    if (imageRect.isEmpty) return;

    final quadPath = Path()
      ..moveTo(quad.topLeft.dx, quad.topLeft.dy)
      ..lineTo(quad.topRight.dx, quad.topRight.dy)
      ..lineTo(quad.bottomRight.dx, quad.bottomRight.dy)
      ..lineTo(quad.bottomLeft.dx, quad.bottomLeft.dy)
      ..close();

    final outerPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final dimPath = Path.combine(PathOperation.difference, outerPath, quadPath);

    final dimPaint = Paint()
      ..color = AppColors.cropDimOverlay
      ..style = PaintingStyle.fill;
    canvas.drawPath(dimPath, dimPaint);

    final quadPaint = Paint()
      ..color = AppColors.primaryLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppSizes.cropQuadStroke;
    canvas.drawPath(quadPath, quadPaint);

    _drawHandles(canvas);
  }

  void _drawHandles(Canvas canvas) {
    final points = quad.points;
    const radius = AppSizes.cropHandleVisible / 2; // 12px

    final handleFill = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.fill;

    final handleStroke = Paint()
      ..color = AppColors.primaryLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final dotFill = Paint()
      ..color = AppColors.primaryLight
      ..style = PaintingStyle.fill;

    final haloPaint = Paint()
      ..color = AppColors.cropHandleHalo
      ..style = PaintingStyle.fill;

    for (var i = 0; i < points.length; i++) {
      final point = points[i];

      if (activeCorner == i) {
        canvas.drawCircle(point, radius + 8, haloPaint);
      }

      canvas.drawCircle(point, radius, handleFill);
      canvas.drawCircle(point, radius, handleStroke);
      canvas.drawCircle(point, 4, dotFill);
    }
  }

  @override
  bool shouldRepaint(covariant CropPainter oldDelegate) {
    return oldDelegate.quad != quad ||
        oldDelegate.imageRect != imageRect ||
        oldDelegate.activeCorner != activeCorner;
  }
}
