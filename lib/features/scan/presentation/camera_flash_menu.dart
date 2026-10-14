import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../domain/camera_service.dart';

class CameraFlashMenu extends StatelessWidget {
  const CameraFlashMenu({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final CameraFlash selected;
  final ValueChanged<CameraFlash> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _FlashOption(
            icon: LucideIcons.zapOff,
            label: 'Off',
            isSelected: selected == CameraFlash.off,
            onTap: () => onSelect(CameraFlash.off),
          ),
          _FlashOption(
            icon: LucideIcons.zap,
            label: 'On',
            isSelected: selected == CameraFlash.on,
            onTap: () => onSelect(CameraFlash.on),
          ),
          _FlashOption(
            icon: LucideIcons.sparkles,
            label: 'Auto',
            isSelected: selected == CameraFlash.auto,
            onTap: () => onSelect(CameraFlash.auto),
          ),
        ],
      ),
    );
  }
}

class _FlashOption extends StatelessWidget {
  const _FlashOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryTint : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.primary : AppColors.textPrimary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
