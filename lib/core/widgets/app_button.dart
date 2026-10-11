import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

enum AppButtonVariant { filled, outlined, text, danger }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.filled,
    this.icon,
    this.loading = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final Widget? icon;
  final bool loading;
  final bool expand;

  static const double _buttonHeight = 52;
  static const double _buttonRadius = AppRadius.md + 2;

  bool get _isEnabled => onPressed != null && !loading;

  @override
  Widget build(BuildContext context) {
    final (bgColor, fgColor, borderColor) = _resolveColors();
    final effectiveOnPressed = _isEnabled ? onPressed : null;

    final childContent = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading) ...[
          SizedBox(
            width: AppSpacing.lg,
            height: AppSpacing.lg,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fgColor),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ] else if (icon != null) ...[
          icon!,
          const SizedBox(width: AppSpacing.sm),
        ],
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: fgColor,
              ),
        ),
      ],
    );

    return SizedBox(
      height: _buttonHeight,
      width: expand ? double.infinity : null,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: AppSpacing.minTouch),
        child: Material(
          color: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(_buttonRadius)),
            side: borderColor != null
                ? BorderSide(color: borderColor, width: 1)
                : BorderSide.none,
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: effectiveOnPressed,
            borderRadius: const BorderRadius.all(Radius.circular(_buttonRadius)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: childContent,
            ),
          ),
        ),
      ),
    );
  }

  (Color, Color, Color?) _resolveColors() {
    if (!_isEnabled) {
      return switch (variant) {
        AppButtonVariant.filled => (
            AppColors.switchOff,
            AppColors.surface,
            null,
          ),
        AppButtonVariant.outlined => (
            Colors.transparent,
            AppColors.textSecondary,
            AppColors.divider,
          ),
        AppButtonVariant.text => (
            Colors.transparent,
            AppColors.textSecondary,
            null,
          ),
        AppButtonVariant.danger => (
            AppColors.switchOff,
            AppColors.surface,
            null,
          ),
      };
    }

    return switch (variant) {
      AppButtonVariant.filled => (
          AppColors.primary,
          AppColors.surface,
          null,
        ),
      AppButtonVariant.outlined => (
          Colors.transparent,
          AppColors.primary,
          AppColors.primary,
        ),
      AppButtonVariant.text => (
          Colors.transparent,
          AppColors.primary,
          null,
        ),
      AppButtonVariant.danger => (
          AppColors.danger,
          AppColors.surface,
          null,
        ),
    };
  }
}
