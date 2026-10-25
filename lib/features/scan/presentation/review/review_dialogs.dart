import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';

enum BackScanAction { saveAndExit, discard }

abstract final class ReviewDialogs {
  static Future<BackScanAction?> showBackScanDialog(BuildContext context, int count) {
    return showDialog<BackScanAction>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
        contentPadding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xxl, AppSpacing.xxl, AppSpacing.xl),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppSizes.actionButton,
              height: AppSizes.actionButton,
              decoration: const BoxDecoration(color: AppColors.primaryTint, shape: BoxShape.circle),
              child: const Icon(LucideIcons.save, color: AppColors.primary, size: 24),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text('Save or Discard?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: AppSpacing.xs),
            Text('You have $count ${count == 1 ? "page" : "pages"} scanned.', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xxl),
            Row(children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(BackScanAction.discard),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                  ),
                  child: const Text('Discard', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.danger)),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(BackScanAction.saveAndExit),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                  ),
                  child: const Text('Save and Exit', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textOnDark)),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  static Future<bool> _showConfirmDialog({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String message,
    required String cancelLabel,
    required String confirmLabel,
    Color cancelColor = AppColors.textSecondary,
    Color confirmBgColor = AppColors.danger,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
        contentPadding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xxl, AppSpacing.xxl, AppSpacing.xl),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppSizes.actionButton,
              height: AppSizes.actionButton,
              decoration: BoxDecoration(color: AppColors.danger.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: AppColors.danger, size: 24),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: AppSpacing.xs),
            Text(message, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xxl),
            Row(children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Text(cancelLabel, style: TextStyle(fontWeight: FontWeight.w600, color: cancelColor)),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: ElevatedButton.styleFrom(backgroundColor: confirmBgColor),
                  child: Text(confirmLabel, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textOnDark)),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
    return result ?? false;
  }

  static Future<bool> showDiscardScanDialog(BuildContext context, int count) => _showConfirmDialog(
        context: context, icon: LucideIcons.triangleAlert, title: 'Discard this scan?',
        message: 'All $count ${count == 1 ? "page" : "pages"} will be lost.',
        cancelLabel: 'Keep', confirmLabel: 'Discard', cancelColor: AppColors.primary,
      );

  static Future<bool> showDeletePageDialog(BuildContext context, int pageNumber) => _showConfirmDialog(
        context: context, icon: LucideIcons.trash2, title: 'Delete this page?',
        message: 'Page $pageNumber will be removed from this scan.',
        cancelLabel: 'Cancel', confirmLabel: 'Delete',
      );

  static Future<String?> showRenameScanDialog(BuildContext context, String currentName) async {
    final controller = TextEditingController(text: currentName);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
        title: const Text('Rename document', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(hintText: 'Document name')),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Save', style: TextStyle(color: AppColors.textOnDark)),
          ),
        ],
      ),
    );
  }
}
