import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../domain/camera_service.dart';

class CameraTopBar extends StatelessWidget {
  const CameraTopBar({
    super.key,
    required this.onBack,
    required this.onFlashTap,
    required this.onGridTap,
    required this.onFlipTap,
    required this.currentFlash,
    required this.isGridVisible,
    required this.showFlip,
  });

  final VoidCallback onBack;
  final VoidCallback onFlashTap;
  final VoidCallback onGridTap;
  final VoidCallback onFlipTap;
  final CameraFlash currentFlash;
  final bool isGridVisible;
  final bool showFlip;

  String _flashTooltip(CameraFlash flash) => switch (flash) {
        CameraFlash.off => 'Flash: Off',
        CameraFlash.auto => 'Flash: Auto',
        CameraFlash.on => 'Flash: On',
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CircleIconButton(
            icon: LucideIcons.x,
            tooltip: 'Cancel',
            onTap: onBack,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CircleIconButton(
                icon: currentFlash == CameraFlash.off ? LucideIcons.zapOff : LucideIcons.zap,
                badgeText: currentFlash == CameraFlash.auto ? 'A' : null,
                tooltip: _flashTooltip(currentFlash),
                isActive: currentFlash != CameraFlash.off,
                onTap: onFlashTap,
              ),
              const SizedBox(width: AppSpacing.sm),
              _CircleIconButton(
                icon: LucideIcons.grid3x3,
                tooltip: 'Grid',
                isActive: isGridVisible,
                onTap: onGridTap,
              ),
              if (showFlip) ...[
                const SizedBox(width: AppSpacing.sm),
                _CircleIconButton(
                  icon: LucideIcons.switchCamera,
                  tooltip: 'Switch Camera',
                  onTap: onFlipTap,
                ),
              ],
              const SizedBox(width: AppSpacing.sm),
              _CircleIconButton(
                icon: LucideIcons.settings,
                tooltip: 'Settings',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.isActive = false,
    this.badgeText,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isActive;
  final String? badgeText;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: AppSizes.topBarButton,
          height: AppSizes.topBarButton,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.cameraControlBg,
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, size: 20, color: AppColors.textOnDark),
              if (badgeText != null)
                Positioned(
                  right: 4,
                  bottom: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: AppColors.cameraBlack.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      badgeText!,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textOnDark,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
