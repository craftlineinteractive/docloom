import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import 'crop_coordinates.dart';

class BookSplitOverlay extends StatelessWidget {
  const BookSplitOverlay({
    super.key,
    required this.splitRatio,
    required this.onChanged,
    required this.imageAspectRatio,
  });

  final double splitRatio;
  final ValueChanged<double> onChanged;
  final double imageAspectRatio;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final boxSize = Size(constraints.maxWidth, constraints.maxHeight);
      final imageRect = CropCoordinates.computeImageRect(
        boxSize: boxSize,
        imageAspectRatio: imageAspectRatio,
      );
      if (imageRect.width <= 0 || imageRect.height <= 0) {
        return const SizedBox.shrink();
      }

      final splitX = imageRect.left + imageRect.width * splitRatio;

      return Positioned(
        left: splitX - 24,
        top: imageRect.top,
        width: 48,
        height: imageRect.height,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: (d) {
            final newRatio = (splitRatio + d.delta.dx / imageRect.width).clamp(0.1, 0.9);
            onChanged(newRatio);
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(AppSizes.splitLineWidth, imageRect.height),
                painter: const _DashedVerticalLinePainter(),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.unfold_more,
                  color: AppColors.textOnDark,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _DashedVerticalLinePainter extends CustomPainter {
  const _DashedVerticalLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = AppSizes.splitLineWidth
      ..style = PaintingStyle.stroke;

    const dashH = 8.0;
    const gapH = 6.0;
    double y = 0;
    final x = size.width / 2;

    while (y < size.height) {
      canvas.drawLine(Offset(x, y), Offset(x, y + dashH), paint);
      y += dashH + gapH;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
