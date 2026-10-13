import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/providers/home_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../folders/domain/folder.dart';
import '../../application/library_actions.dart';
import 'folder_color_dialog.dart';
import 'folder_edit_dialog.dart';

class FolderActionsSheet extends ConsumerWidget {
  const FolderActionsSheet({
    super.key,
    required this.folder,
    this.onDeletedFromScreen,
  });

  final Folder folder;
  final VoidCallback? onDeletedFromScreen;

  static Future<void> show(
    BuildContext context, {
    required Folder folder,
    VoidCallback? onDeletedFromScreen,
  }) {
    return showAppBottomSheet<void>(
      context,
      title: folder.name,
      child: FolderActionsSheet(
        folder: folder,
        onDeletedFromScreen: onDeletedFromScreen,
      ),
    );
  }

  Widget _buildRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    final effectiveColor = color ?? AppColors.textPrimary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Row(
          children: [
            Icon(icon, size: 20, color: effectiveColor),
            const SizedBox(width: AppSpacing.md),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: effectiveColor,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final actions = ref.read(libraryActionsProvider);
    final container = ProviderScope.containerOf(context, listen: false);
    final confirmed = await showAppDialog(
      context,
      title: 'Delete folder',
      body: 'Delete this folder? Documents inside will move to Trash with it.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (confirmed != true) return;
    if (context.mounted) Navigator.of(context).pop();
    if (onDeletedFromScreen != null) onDeletedFromScreen!();
    try {
      await actions.deleteFolder(folder.id);
      container.refreshLibrary();
      showAppToastWithMessenger(
        messenger,
        'Folder moved to Trash',
        actionLabel: 'Undo',
        duration: const Duration(seconds: 5),
        onAction: () async {
          await actions.undoDeleteFolder(folder.id);
          container.refreshLibrary();
        },
      );
    } on AppException catch (e) {
      showAppToastWithMessenger(messenger, e.message);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildRow(
          context: context,
          icon: LucideIcons.pencil,
          title: 'Rename',
          onTap: () {
            Navigator.of(context).pop();
            FolderEditDialog.showRename(
              context,
              folderId: folder.id,
              currentName: folder.name,
              currentColorIndex: folder.colorIndex,
            );
          },
        ),
        _buildRow(
          context: context,
          icon: LucideIcons.palette,
          title: 'Change color',
          onTap: () {
            Navigator.of(context).pop();
            FolderColorDialog.show(
              context,
              folderId: folder.id,
              currentColorIndex: folder.colorIndex,
            );
          },
        ),
        _buildRow(
          context: context,
          icon: LucideIcons.trash2,
          title: 'Delete',
          color: AppColors.danger,
          onTap: () => _handleDelete(context, ref),
        ),
      ],
    );
  }
}
