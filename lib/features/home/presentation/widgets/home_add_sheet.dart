import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';

class HomeAddSheet extends StatelessWidget {
  const HomeAddSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showAppBottomSheet<void>(
      context,
      title: 'Add Document',
      child: const HomeAddSheet(),
    );
  }

  Widget _buildRow({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        showAppToast(context, 'Import comes in a later phase');
      },
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Center(child: Icon(icon, color: iconColor, size: 22)),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.hairline),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              LucideIcons.chevronRight,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildRow(
          context: context,
          icon: LucideIcons.image,
          iconColor: AppColors.primary,
          title: 'From Gallery',
          description: 'Import photos and existing images from device storage',
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildRow(
          context: context,
          icon: LucideIcons.fileImage,
          iconColor: AppColors.folderOrange,
          title: 'PDF as Image',
          description: 'Convert & extract pages from existing PDF files as photos',
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildRow(
          context: context,
          icon: LucideIcons.cloudUpload,
          iconColor: AppColors.folderGreen,
          title: 'Import Documents',
          description: 'Browse files, cloud storage, Google Drive, or Word docs',
        ),
      ],
    );
  }
}
