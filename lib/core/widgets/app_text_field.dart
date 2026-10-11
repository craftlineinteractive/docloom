import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.obscure = false,
    this.onChanged,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final bool obscure;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(AppRadius.md));

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        TextField(
          controller: controller,
          obscureText: obscure,
          onChanged: onChanged,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            errorText: errorText,
            errorStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.danger,
                ),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            border: const OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide(color: AppColors.divider, width: 1),
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide(color: AppColors.divider, width: 1),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide(color: AppColors.danger, width: 1),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide(color: AppColors.danger, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
