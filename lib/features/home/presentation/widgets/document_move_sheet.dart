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

class DocumentMoveSheet extends ConsumerWidget {
  const DocumentMoveSheet({
    super.key,
    this.document,
    this.documentIds,
    this.currentFolderId,
  });

  final Document? document;
  final List<String>? documentIds;
  final String? currentFolderId;

  static Future<void> show(BuildContext context, {required Document document}) {
    return showAppBottomSheet<void>(
      context,
      title: 'Move to folder',
      child: DocumentMoveSheet(
        document: document,
        currentFolderId: document.folderId,
      ),
    );
  }

  static Future<void> showBatch(
    BuildContext context, {
    required List<String> documentIds,
    String? currentFolderId,
  }) {
    return showAppBottomSheet<void>(
      context,
      title: 'Move to folder',
      child: DocumentMoveSheet(
        documentIds: documentIds,
        currentFolderId: currentFolderId,
      ),
    );
  }

  Future<void> _move(BuildContext context, WidgetRef ref, String? targetFolderId, String label) async {
    Navigator.of(context).pop();
    try {
      if (documentIds != null) {
        await ref.read(libraryActionsProvider).moveDocuments(
              ids: documentIds!,
              targetFolderId: targetFolderId,
            );
        ref.read(selectModeProvider.notifier).exit();
        ref.read(selectionProvider.notifier).clear();
        ref.refreshLibrary();
        if (context.mounted) showAppToast(context, 'Moved ${documentIds!.length} items to $label');
      } else if (document != null) {
        await ref.read(libraryActionsProvider).moveDocument(
              id: document!.id,
              targetFolderId: targetFolderId,
            );
        ref.refreshLibrary();
        if (context.mounted) showAppToast(context, 'Moved to $label');
      }
    } on AppException catch (e) {
      if (context.mounted) showAppToast(context, e.message);
    }
  }

  Widget _buildItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isCurrent,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isCurrent ? null : onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isCurrent ? AppColors.primary : AppColors.textPrimary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isCurrent ? AppColors.primary : AppColors.textPrimary,
                      fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                    ),
              ),
            ),
            if (isCurrent) const Icon(LucideIcons.check, size: 18, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foldersAsync = ref.watch(foldersProvider);
    final folders = foldersAsync.value ?? const [];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildItem(
          context,
          title: 'Home (Root)',
          icon: LucideIcons.home,
          isCurrent: currentFolderId == null,
          onTap: () => _move(context, ref, null, 'Home'),
        ),
        for (final f in folders)
          _buildItem(
            context,
            title: f.folder.name,
            icon: LucideIcons.folder,
            isCurrent: currentFolderId == f.folder.id,
            onTap: () => _move(context, ref, f.folder.id, f.folder.name),
          ),
      ],
    );
  }
}
