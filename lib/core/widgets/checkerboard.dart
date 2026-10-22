import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';

class Checkerboard extends StatelessWidget {
  const Checkerboard({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _CheckerboardPainter(),
      child: child,
    );
  }
}

class _CheckerboardPainter extends CustomPainter {
  const _CheckerboardPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final lightPaint = Paint()..color = AppColors.checkerLight;
    final darkPaint = Paint()..color = AppColors.checkerDark;

    const square = AppSizes.checkerSquare;
    final cols = (size.width / square).ceil();
    final rows = (size.height / square).ceil();

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final paint = (r + c) % 2 == 0 ? lightPaint : darkPaint;
        canvas.drawRect(
          Rect.fromLTWH(c * square, r * square, square, square),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
