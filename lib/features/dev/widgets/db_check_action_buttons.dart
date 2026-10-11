import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';

class DbCheckActionButtons extends StatelessWidget {
  const DbCheckActionButtons({
    super.key,
    required this.onCreateFolder,
    required this.onCreateDocument,
    required this.onTrashNewestDoc,
    required this.onRestoreNewestDoc,
    required this.onEmptyTrash,
    required this.busy,
  });

  final VoidCallback onCreateFolder;
  final VoidCallback onCreateDocument;
  final VoidCallback onTrashNewestDoc;
  final VoidCallback onRestoreNewestDoc;
  final VoidCallback onEmptyTrash;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppButton(
          label: 'Create Folder',
          icon: const Icon(LucideIcons.folderPlus, size: 18, color: AppColors.surface),
          onPressed: busy ? null : onCreateFolder,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: 'Create Document (2 Pages)',
          icon: const Icon(LucideIcons.filePlus2, size: 18, color: AppColors.surface),
          onPressed: busy ? null : onCreateDocument,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: 'Trash Newest Root Doc',
          icon: const Icon(LucideIcons.trash2, size: 18, color: AppColors.surface),
          variant: AppButtonVariant.outlined,
          onPressed: busy ? null : onTrashNewestDoc,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: 'Restore Newest Trashed Doc',
          icon: const Icon(LucideIcons.archiveRestore, size: 18, color: AppColors.surface),
          variant: AppButtonVariant.outlined,
          onPressed: busy ? null : onRestoreNewestDoc,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: 'Empty Trash',
          icon: const Icon(LucideIcons.trash, size: 18, color: AppColors.surface),
          variant: AppButtonVariant.danger,
          onPressed: busy ? null : onEmptyTrash,
        ),
      ],
    );
  }
}
