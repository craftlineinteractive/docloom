import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/providers/home_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../documents/domain/document.dart';
import '../../application/library_actions.dart';
import 'document_move_sheet.dart';
import 'document_rename_dialog.dart';

class DocumentActionsSheet extends ConsumerWidget {
  const DocumentActionsSheet({super.key, required this.document});

  final Document document;

  static Future<void> show(BuildContext context, {required Document document}) {
    return showAppBottomSheet<void>(
      context,
      title: document.name,
      child: DocumentActionsSheet(document: document),
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
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
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
    Navigator.of(context).pop();
    try {
      await actions.deleteDocument(document.id);
      container.refreshLibrary();
      showAppToastWithMessenger(
        messenger,
        'Moved to Trash',
        actionLabel: 'Undo',
        duration: const Duration(seconds: 5),
        onAction: () async {
          final res = await actions.undoDeleteDocument(document.id);
          container.refreshLibrary();
          if (res.restoredToRoot) showAppToastWithMessenger(messenger, 'Restored to Home');
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
            DocumentRenameDialog.show(context, documentId: document.id, currentName: document.name);
          },
        ),
        _buildRow(
          context: context,
          icon: document.isFavorite ? LucideIcons.heartOff : LucideIcons.heart,
          title: document.isFavorite ? 'Unfavorite' : 'Favorite',
          onTap: () async {
            final messenger = ScaffoldMessenger.of(context);
            final actions = ref.read(libraryActionsProvider);
            final container = ProviderScope.containerOf(context, listen: false);
            Navigator.of(context).pop();
            try {
              await actions.toggleFavorite(id: document.id, currentIsFavorite: document.isFavorite);
              container.refreshLibrary();
            } on AppException catch (e) {
              showAppToastWithMessenger(messenger, e.message);
            }
          },
        ),
        _buildRow(
          context: context,
          icon: LucideIcons.folderInput,
          title: 'Move to folder',
          onTap: () {
            Navigator.of(context).pop();
            DocumentMoveSheet.show(context, document: document);
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
