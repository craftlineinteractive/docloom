import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';

class ReviewToolbar extends StatelessWidget {
  const ReviewToolbar({
    super.key,
    required this.onCrop,
    required this.onColor,
    required this.onRotate,
    required this.onArrange,
    required this.onRetake,
    required this.onDelete,
    required this.onCheck,
    this.isColorActive = false,
  });

  final VoidCallback onCrop;
  final VoidCallback onColor;
  final VoidCallback onRotate;
  final VoidCallback onArrange;
  final VoidCallback onRetake;
  final VoidCallback onDelete;
  final VoidCallback onCheck;
  final bool isColorActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ToolButton(label: 'Crop', icon: LucideIcons.crop, onTap: onCrop),
                _ToolButton(
                  label: 'Color',
                  icon: LucideIcons.palette,
                  isActive: isColorActive,
                  onTap: onColor,
                ),
                _ToolButton(label: 'Rotate', icon: LucideIcons.rotateCw, onTap: onRotate),
                _ToolButton(label: 'Arrange', icon: LucideIcons.grid2x2, onTap: onArrange),
                _ToolButton(label: 'Retake', icon: LucideIcons.camera, onTap: onRetake),
                _ToolButton(
                  label: 'Delete',
                  icon: LucideIcons.trash2,
                  isDestructive: true,
                  onTap: onDelete,
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 32,
            child: VerticalDivider(width: 16, color: AppColors.divider),
          ),
          GestureDetector(
            onTap: onCheck,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: AppSizes.actionButton,
              height: AppSizes.actionButton,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(LucideIcons.check, color: AppColors.textOnDark, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isActive = false,
    this.isDestructive = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? AppColors.danger
        : (isActive ? AppColors.primary : AppColors.textPrimary);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryTint : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
