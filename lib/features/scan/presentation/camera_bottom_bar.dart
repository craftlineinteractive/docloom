import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';

class CameraBottomBar extends StatelessWidget {
  const CameraBottomBar({
    super.key,
    required this.onCapture,
    required this.isEnabled,
    this.isCapturing = false,
    this.isQrMode = false,
    this.leftSlot,
    this.rightSlot,
  });

  final VoidCallback onCapture;
  final bool isEnabled;
  final bool isCapturing;
  final bool isQrMode;
  final Widget? leftSlot;
  final Widget? rightSlot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.md,
        AppSpacing.xxl,
        AppSpacing.xxl,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          leftSlot ??
              const SizedBox(
                width: AppSizes.bottomSlotButton,
                height: AppSizes.bottomSlotButton,
              ),
          if (isQrMode)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.cameraControlBg,
                borderRadius: BorderRadius.circular(AppSizes.bottomSlotButton),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(color: AppColors.autoDetectGreen, shape: BoxShape.circle),
                    child: SizedBox(width: AppSizes.qrAutoDetectDot, height: AppSizes.qrAutoDetectDot),
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    'Auto Detect',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textOnDark),
                  ),
                ],
              ),
            )
          else
            _ShutterButton(
              onTap: isEnabled ? onCapture : null,
              isEnabled: isEnabled,
              isCapturing: isCapturing,
            ),
          rightSlot ??
              const SizedBox(
                width: AppSizes.bottomSlotButton,
                height: AppSizes.bottomSlotButton,
              ),
        ],
      ),
    );
  }
}

class _ShutterButton extends StatefulWidget {
  const _ShutterButton({
    required this.onTap,
    required this.isEnabled,
    required this.isCapturing,
  });

  final VoidCallback? onTap;
  final bool isEnabled;
  final bool isCapturing;

  @override
  State<_ShutterButton> createState() => _ShutterButtonState();
}

class _ShutterButtonState extends State<_ShutterButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.isEnabled && widget.onTap != null;
    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: enabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: enabled ? () => setState(() => _isPressed = false) : null,
      onTap: widget.onTap,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: AnimatedScale(
          scale: _isPressed ? 0.94 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            width: AppSizes.shutterOuter,
            height: AppSizes.shutterOuter,
            padding: const EdgeInsets.all(AppSizes.shutterPadding),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.textOnDark,
                width: 3,
              ),
            ),
            child: widget.isCapturing
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),
                  )
                : Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.textOnDark,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
