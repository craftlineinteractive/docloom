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
    const padding = 16.0;

    final isLeftHalf = focalPoint.dx < boxSize.width / 2;
    final left = isLeftHalf ? (boxSize.width - size - padding) : padding;
    const top = padding;

    final center = Offset(left + size / 2, top + size / 2);
    final focalOffset = focalPoint - center;

    return Positioned(
      left: left,
      top: top,
      width: size,
      height: size,
      child: IgnorePointer(
        child: RawMagnifier(
          size: const Size(size, size),
          magnificationScale: 2.5,
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
          child: const _CrossCenterOverlay(),
        ),
      ),
    );
  }
}

class _CrossCenterOverlay extends StatelessWidget {
  const _CrossCenterOverlay();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(AppSizes.cropMagnifier, AppSizes.cropMagnifier),
      painter: const _PlusCenterPainter(),
    );
  }
}

class _PlusCenterPainter extends CustomPainter {
  const _PlusCenterPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const arm = 8.0;

    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(cx - arm, cy), Offset(cx + arm, cy), linePaint);
    canvas.drawLine(Offset(cx, cy - arm), Offset(cx, cy + arm), linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
