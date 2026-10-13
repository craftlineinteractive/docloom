import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/providers/home_providers.dart';
import '../../../core/widgets/widgets.dart';
import '../../home/presentation/widgets/batch_delete_action.dart';
import '../../home/presentation/widgets/document_list_sliver.dart';
import '../../home/presentation/widgets/document_move_sheet.dart';
import '../../home/presentation/widgets/folder_actions_sheet.dart';
import '../../home/presentation/widgets/home_add_sheet.dart';
import '../../home/presentation/widgets/home_overflow_menu.dart';
import '../../home/presentation/widgets/select_action_bar.dart';

class FolderScreen extends ConsumerWidget {
  const FolderScreen({super.key, required this.folderId});

  final String folderId;

  void _exitSelect(WidgetRef ref) {
    ref.read(selectModeProvider.notifier).exit();
    ref.read(selectionProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folderAsync = ref.watch(folderByIdProvider(folderId));
    final docsAsync = ref.watch(documentsProvider(folderId));
    final isSelect = ref.watch(selectModeProvider);
    final selected = ref.watch(selectionProvider);

    if (folderAsync.isLoading && !folderAsync.hasValue) {
      return const Scaffold(
        appBar: AppTopBar(title: 'Folder', showBack: true),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final folder = folderAsync.value;
    if (folder == null) {
      return Scaffold(
        appBar: const AppTopBar(title: 'Folder', showBack: true),
        body: EmptyState(
          icon: LucideIcons.folderX,
          title: 'This folder is no longer available',
          body: 'It may have been moved to Trash or deleted.',
          actionLabel: 'Back',
          onAction: () {
            _exitSelect(ref);
            Navigator.of(context).maybePop();
          },
        ),
      );
    }

    final docs = docsAsync.value ?? const [];

    final appBar = isSelect
        ? AppTopBar(
            title: '${selected.length} selected',
            leading: AppIconButton(icon: LucideIcons.x, tooltip: 'Cancel', onPressed: () => _exitSelect(ref)),
            actions: [
              AppIconButton(
                icon: LucideIcons.checkCheck,
                tooltip: 'Select all',
                onPressed: () => ref.read(selectionProvider.notifier).selectAll(docs.map((d) => d.document.id)),
              ),
            ],
          )
        : AppTopBar(
            title: folder.name,
            showBack: true,
            leading: AppIconButton(
              icon: LucideIcons.arrowLeft,
              tooltip: 'Back',
              onPressed: () {
                _exitSelect(ref);
                Navigator.of(context).maybePop();
              },
            ),
            actions: [
              AppIconButton(
                icon: LucideIcons.folderCog,
                tooltip: 'Folder options',
                onPressed: () => FolderActionsSheet.show(
                  context,
                  folder: folder,
                  onDeletedFromScreen: () {
                    _exitSelect(ref);
                    Navigator.of(context).maybePop();
                  },
                ),
              ),
              const HomeOverflowMenu(isHome: false),
            ],
          );

    return PopScope(
      canPop: !isSelect,
      onPopInvokedWithResult: (didPop, _) {
        _exitSelect(ref);
      },
      child: Scaffold(
        appBar: appBar,
        bottomNavigationBar: isSelect
            ? SelectActionBar(
                selectedCount: selected.length,
                onMove: () => DocumentMoveSheet.showBatch(
                  context,
                  documentIds: selected.toList(),
                  currentFolderId: folderId,
                ),
                onDelete: () => batchDeleteWithToast(context, ref, selected.toList()),
              )
            : null,
        floatingActionButton: isSelect
            ? null
            : FabPill(
                onCamera: () => showAppToast(context, 'Scanning arrives in Phase 4'),
                onAdd: () => HomeAddSheet.show(context),
              ),
        body: CustomScrollView(
          slivers: [
            DocumentListSliver(folderId: folderId),
          ],
        ),
      ),
    );
  }
}


