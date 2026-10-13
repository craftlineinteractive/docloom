import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

class SelectActionBar extends StatelessWidget {
  const SelectActionBar({
    super.key,
    required this.selectedCount,
    required this.onMove,
    required this.onDelete,
  });

  final int selectedCount;
  final VoidCallback onMove;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final hasSelection = selectedCount > 0;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(LucideIcons.folderInput, size: 18),
                label: const Text('Move'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: hasSelection ? AppColors.textPrimary : AppColors.textSecondary,
                  side: BorderSide(color: hasSelection ? AppColors.divider : AppColors.pageBackdrop),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
                onPressed: hasSelection ? onMove : null,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: FilledButton.icon(
                icon: const Icon(LucideIcons.trash2, size: 18),
                label: const Text('Delete'),
                style: FilledButton.styleFrom(
                  backgroundColor: hasSelection ? AppColors.danger : AppColors.pageBackdrop,
                  foregroundColor: hasSelection ? Colors.white : AppColors.textSecondary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
                onPressed: hasSelection ? onDelete : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
