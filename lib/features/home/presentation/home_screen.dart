import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/router/routes.dart';
import '../../../core/providers/home_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/time/relative_time.dart';
import '../../../core/widgets/widgets.dart';
import 'widgets/document_list_sliver.dart';
import 'widgets/folder_actions_sheet.dart';
import 'widgets/folder_card.dart';
import 'widgets/folder_edit_dialog.dart';
import 'widgets/home_add_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foldersAsync = ref.watch(foldersProvider);
    final docsAsync = ref.watch(documentsProvider(null));

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
    final isEmpty = folders.isEmpty && docs.isEmpty;

    return Scaffold(
      appBar: AppTopBar(
        title: 'docLoom',
        actions: [
          AppIconButton(icon: LucideIcons.search, tooltip: 'Search', onPressed: () {}),
          AppIconButton(icon: LucideIcons.moreVertical, tooltip: 'More options', onPressed: () {}),
          if (kDebugMode)
            AppIconButton(icon: LucideIcons.layoutGrid, tooltip: 'Component Gallery', onPressed: () => context.push(Routes.gallery)),
        ],
      ),
      floatingActionButton: FabPill(
        onCamera: () => showAppToast(context, 'Scanning arrives in Phase 4'),
        onAdd: () => HomeAddSheet.show(context),
      ),
      body: CustomScrollView(
        slivers: [
          if (isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: LucideIcons.fileText,
                title: 'Scan your first document',
                body: 'Digitize receipts, ID cards, notes, or\nimport existing files effortlessly.',
              ),
            )
          else ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, AppSpacing.sm, AppSpacing.screenH, 0),
                child: SectionHeader(
                  title: 'Folders',
                  count: folders.length,
                  trailing: AppIconButton(
                    icon: LucideIcons.folderPlus,
                    tooltip: 'Create folder',
                    onPressed: () => FolderEditDialog.showCreate(context),
                  ),
                ),
              ),
            ),
            if (folders.isNotEmpty) ...[
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: AppSpacing.sm,
                    mainAxisSpacing: AppSpacing.sm,
                    childAspectRatio: 0.9,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final f = folders[index];
                      final color = AppColors.folderPalette[f.folder.colorIndex % AppColors.folderPalette.length];
                      final countText = '${f.itemCount} ${f.itemCount == 1 ? 'item' : 'items'} - ${shortDate(f.folder.updatedAt)}';
                      return FolderCard(
                        key: ValueKey(f.folder.id),
                        item: FolderItem(name: f.folder.name, itemCountAndDate: countText, color: color),
                        onTap: () => context.push(Routes.folderPath(f.folder.id)),
                        onLongPress: () => FolderActionsSheet.show(context, folder: f.folder),
                      );
                    },
                    childCount: folders.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
            ],
            const DocumentListSliver(folderId: null),
          ],
        ],
      ),
    );
  }
}
