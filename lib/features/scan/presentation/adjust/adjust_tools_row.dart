import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class AdjustToolsRow extends StatelessWidget {
  const AdjustToolsRow({
    super.key,
    required this.onRotate,
    required this.onReset,
    this.onAutoDetect,
    this.isDetecting = false,
  });

  final VoidCallback onRotate;
  final VoidCallback onReset;
  final VoidCallback? onAutoDetect;
  final bool isDetecting;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: AppColors.gridLine, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (onAutoDetect != null)
            _ToolButton(
              icon: isDetecting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textOnDark,
                      ),
                    )
                  : const Icon(LucideIcons.scanLine, color: AppColors.textOnDark, size: 20),
              label: isDetecting ? 'Detecting...' : 'Auto detect',
              onTap: isDetecting ? () {} : onAutoDetect!,
            ),
          _ToolButton(
            icon: const Icon(LucideIcons.rotateCw, color: AppColors.textOnDark, size: 20),
            label: 'Rotate',
            onTap: onRotate,
          ),
          _ToolButton(
            icon: const Icon(LucideIcons.rotateCcw, color: AppColors.textOnDark, size: 20),
            label: 'Reset',
            onTap: onReset,
          ),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Widget icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(height: AppSpacing.xs / 2),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textOnDark,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
