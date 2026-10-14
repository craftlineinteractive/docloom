import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/router/routes.dart';
import '../../../core/providers/home_providers.dart';
import '../../../core/widgets/widgets.dart';
import '../../scan/application/scan_providers.dart';
import 'widgets/batch_delete_action.dart';
import 'widgets/document_list_sliver.dart';
import 'widgets/document_move_sheet.dart';
import 'widgets/folders_section_sliver.dart';
import 'widgets/home_add_sheet.dart';
import 'widgets/home_overflow_menu.dart';
import 'widgets/select_action_bar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _exitSelect(WidgetRef ref) {
    ref.read(selectModeProvider.notifier).exit();
    ref.read(selectionProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foldersAsync = ref.watch(foldersProvider);
    final docsAsync = ref.watch(documentsProvider(null));
    final isSelect = ref.watch(selectModeProvider);
    final selected = ref.watch(selectionProvider);

    if ((foldersAsync.isLoading && !foldersAsync.hasValue) || (docsAsync.isLoading && !docsAsync.hasValue)) {
      return const Scaffold(appBar: AppTopBar(title: 'docLoom'), body: Center(child: CircularProgressIndicator()));
    }
    if ((foldersAsync.hasError && !foldersAsync.hasValue) || (docsAsync.hasError && !docsAsync.hasValue)) {
      return Scaffold(
        appBar: const AppTopBar(title: 'docLoom'),
        body: EmptyState(
          icon: LucideIcons.alertCircle,
          title: 'Failed to load',
          body: 'Could not load your library.',
          actionLabel: 'Try again',
          onAction: () => ref.refreshLibrary(),
        ),
      );
    }

    final folders = foldersAsync.value ?? const [];
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
            title: 'docLoom',
            actions: [
              AppIconButton(icon: LucideIcons.search, tooltip: 'Search', onPressed: () => context.push(Routes.search)),
              const HomeOverflowMenu(isHome: true),
            ],
          );

    return PopScope(
      canPop: !isSelect,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _exitSelect(ref);
      },
      child: Scaffold(
        appBar: appBar,
        bottomNavigationBar: isSelect
            ? SelectActionBar(
                selectedCount: selected.length,
                onMove: () => DocumentMoveSheet.showBatch(context, documentIds: selected.toList()),
                onDelete: () => batchDeleteWithToast(context, ref, selected.toList()),
              )
            : null,
        floatingActionButton: isSelect
            ? null
            : FabPill(
                onCamera: () => ref.read(scanControllerProvider.notifier).startScan(),
                onAdd: () => HomeAddSheet.show(context),
              ),
        body: CustomScrollView(
          slivers: [
            FoldersSectionSliver(folders: folders),
            const DocumentListSliver(folderId: null),
          ],
        ),
      ),
    );
  }
}
