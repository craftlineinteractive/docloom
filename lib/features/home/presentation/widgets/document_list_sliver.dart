import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/providers/home_providers.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/time/relative_time.dart';
import '../../../../core/widgets/widgets.dart';
import 'document_actions_sheet.dart';
import 'document_card.dart';
import 'document_grid_tile.dart';

class DocumentListSliver extends ConsumerWidget {
  const DocumentListSliver({super.key, this.folderId});

  final String? folderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(documentsProvider(folderId));
    final clock = ref.watch(clockProvider);
    final viewMode = ref.watch(viewModeProvider);
    final isSelectMode = ref.watch(selectModeProvider);
    final selection = ref.watch(selectionProvider);
    final docs = docsAsync.value ?? const [];

    if (docs.isEmpty && folderId != null && !docsAsync.isLoading) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyState(
          icon: LucideIcons.fileText,
          title: 'No documents yet',
          body: 'Add documents using the + button.',
        ),
      );
    }

    Widget buildItem(BuildContext context, int index, {required bool isGrid}) {
      final doc = docs[index];
      final docId = doc.document.id;
      final pageCount = '${doc.pageCount} ${doc.pageCount == 1 ? 'page' : 'pages'}';
      final item = DocumentItem(
        name: doc.document.name,
        date: relativeTime(doc.document.updatedAt, clock()),
        pageCount: pageCount,
        coverPath: doc.coverPath,
        isFavorite: doc.document.isFavorite,
      );
      final isSelected = selection.contains(docId);

      void handleToggle() => ref.read(selectionProvider.notifier).toggle(docId);
      void handleLongPress() {
        ref.read(selectModeProvider.notifier).enter();
        ref.read(selectionProvider.notifier).toggle(docId);
      }

      if (isGrid) {
        return DocumentGridTile(
          key: ValueKey(docId),
          item: item,
          selectable: isSelectMode,
          isSelected: isSelected,
          onSelectToggle: handleToggle,
          onLongPress: isSelectMode ? null : handleLongPress,
          onTap: isSelectMode ? handleToggle : () => showAppToast(context, 'Viewer comes in a later phase'),
          onOptionsPressed: () => DocumentActionsSheet.show(context, document: doc.document),
        );
      }

      return DocumentCard(
        key: ValueKey(docId),
        item: item,
        selectable: isSelectMode,
        isSelected: isSelected,
        onSelectToggle: handleToggle,
        onLongPress: isSelectMode ? null : handleLongPress,
        onTap: isSelectMode ? handleToggle : () => showAppToast(context, 'Viewer comes in a later phase'),
        onOptionsPressed: () => DocumentActionsSheet.show(context, document: doc.document),
      );
    }

    final sliverBody = viewMode == ViewMode.grid
        ? SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
              childAspectRatio: 0.78,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => buildItem(context, index, isGrid: true),
              childCount: docs.length,
            ),
          )
        : SliverList.separated(
            itemCount: docs.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) => buildItem(context, index, isGrid: false),
          );

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, AppSpacing.sm, AppSpacing.screenH, 0),
            child: SectionHeader(title: 'Documents', count: docs.length),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
          sliver: sliverBody,
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSizes.bottomClearance)),
      ],
    );
  }
}
