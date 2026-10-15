import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';

class CropMagnifier extends StatelessWidget {
  const CropMagnifier({
    super.key,
    required this.focalPoint,
    required this.boxSize,
  });

  final Offset focalPoint;
  final Size boxSize;

  @override
  Widget build(BuildContext context) {
    const size = AppSizes.cropMagnifier;
    const half = size / 2;
    const offsetAbove = 72.0;

    var left = focalPoint.dx - half;
    var top = focalPoint.dy - half - offsetAbove;

    if (top < 8) {
      top = focalPoint.dy + 32;
    }
    left = left.clamp(8.0, (boxSize.width - size - 8.0).clamp(8.0, double.infinity));
    top = top.clamp(8.0, (boxSize.height - size - 8.0).clamp(8.0, double.infinity));

    final center = Offset(left + half, top + half);
    final focalOffset = focalPoint - center;

    return Positioned(
      left: left,
      top: top,
      width: size,
      height: size,
      child: IgnorePointer(
        child: RawMagnifier(
          size: const Size(size, size),
          magnificationScale: 2.0,
          focalPointOffset: focalOffset,
          decoration: const MagnifierDecoration(
            shape: CircleBorder(
              side: BorderSide(color: AppColors.surface, width: 2),
            ),
            shadows: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const _CrosshairOverlay(),
        ),
      ),
    );
  }
}

class _CrosshairOverlay extends StatelessWidget {
  const _CrosshairOverlay();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(AppSizes.cropMagnifier, AppSizes.cropMagnifier),
      painter: const _CrosshairPainter(),
    );
  }
}

class _CrosshairPainter extends CustomPainter {
  const _CrosshairPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final linePaint = Paint()
      ..color = AppColors.primaryLight
      ..strokeWidth = 1.0;

    // Cross lines
    canvas.drawLine(Offset(0, cy), Offset(size.width, cy), linePaint);
    canvas.drawLine(Offset(cx, 0), Offset(cx, size.height), linePaint);

    // Target circle
    final circlePaint = Paint()
      ..color = AppColors.primaryLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(Offset(cx, cy), 10, circlePaint);

    final dotPaint = Paint()
      ..color = AppColors.primaryLight
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), 2.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
