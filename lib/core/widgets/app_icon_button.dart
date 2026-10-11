import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.color,
    this.size = 24,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.textPrimary;

    return Tooltip(
      message: tooltip,
      child: Semantics(
        label: tooltip,
        button: true,
        enabled: onPressed != null,
        child: SizedBox(
          width: AppSpacing.minTouch,
          height: AppSpacing.minTouch,
          child: Material(
            type: MaterialType.transparency,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              customBorder: const CircleBorder(),
              child: Center(
                child: Icon(
                  icon,
                  size: size,
                  color: onPressed != null
                      ? effectiveColor
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
