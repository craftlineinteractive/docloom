import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class PhotoSizeDialogFooter extends StatelessWidget {
  const PhotoSizeDialogFooter({
    super.key,
    required this.onClose,
    required this.onAddNew,
    required this.onSelect,
  });

  final VoidCallback onClose;
  final VoidCallback onAddNew;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: onClose,
          style: OutlinedButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            foregroundColor: AppColors.textSecondary,
            side: const BorderSide(color: AppColors.cardBorder),
          ),
          child: const Text('Close', style: TextStyle(fontSize: 12)),
        ),
        const SizedBox(width: AppSpacing.xs),
        OutlinedButton(
          onPressed: onAddNew,
          style: OutlinedButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
          ),
          child: const Text('Add New', style: TextStyle(fontSize: 12)),
        ),
        const SizedBox(width: AppSpacing.xs),
        ElevatedButton(
          onPressed: onSelect,
          style: ElevatedButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnDark,
          ),
          child: const Text('Select', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }
}
