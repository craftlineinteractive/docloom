import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';

class QrCutoutOverlay extends StatefulWidget {
  const QrCutoutOverlay({super.key});

  @override
  State<QrCutoutOverlay> createState() => _QrCutoutOverlayState();
}

class _QrCutoutOverlayState extends State<QrCutoutOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const size = AppSizes.qrCutoutSize;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: Stack(
              children: [
                const Positioned.fill(
                  child: CustomPaint(painter: _QrCornerPainter()),
                ),
                const Center(
                  child: Icon(
                    Icons.qr_code_2,
                    size: 120,
                    color: AppColors.qrCodeGraphic,
                  ),
                ),
                AnimatedBuilder(
                  animation: _animCtrl,
                  builder: (context, _) {
                    final top = _animCtrl.value * (size - AppSizes.qrLaserHeight);
                    return Positioned(
                      top: top,
                      left: AppSpacing.sm,
                      right: AppSpacing.sm,
                      child: Container(
                        height: AppSizes.qrLaserHeight,
                        decoration: BoxDecoration(
                          color: AppColors.qrLaser,
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.qrLaserGlow,
                              blurRadius: AppSizes.qrLaserGlowSpread,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'Align QR code within the frame',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textOnDark,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Automatic scanning enabled',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textOnDarkMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _QrCornerPainter extends CustomPainter {
  const _QrCornerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = AppSizes.qrCornerThickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const len = AppSizes.qrCornerLength;
    const r = AppSizes.qrCornerRadius;

    final tl = Path()..moveTo(0, len)..lineTo(0, r)..arcToPoint(const Offset(r, 0), radius: const Radius.circular(r))..lineTo(len, 0);
    canvas.drawPath(tl, paint);

    final tr = Path()..moveTo(size.width - len, 0)..lineTo(size.width - r, 0)..arcToPoint(Offset(size.width, r), radius: const Radius.circular(r))..lineTo(size.width, len);
    canvas.drawPath(tr, paint);

    final bl = Path()..moveTo(0, size.height - len)..lineTo(0, size.height - r)..arcToPoint(Offset(r, size.height), radius: const Radius.circular(r))..lineTo(len, size.height);
    canvas.drawPath(bl, paint);

    final br = Path()..moveTo(size.width - len, size.height)..lineTo(size.width - r, size.height)..arcToPoint(Offset(size.width, size.height - r), radius: const Radius.circular(r))..lineTo(size.width, size.height - len);
    canvas.drawPath(br, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
