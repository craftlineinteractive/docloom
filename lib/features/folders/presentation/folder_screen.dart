import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/providers/home_providers.dart';
import '../../../core/widgets/widgets.dart';
import '../../home/presentation/widgets/document_list_sliver.dart';
import '../../home/presentation/widgets/folder_actions_sheet.dart';
import '../../home/presentation/widgets/home_add_sheet.dart';

class FolderScreen extends ConsumerWidget {
  const FolderScreen({super.key, required this.folderId});

  final String folderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folderAsync = ref.watch(folderByIdProvider(folderId));

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
          onAction: () => Navigator.of(context).maybePop(),
        ),
      );
    }

    return Scaffold(
      appBar: AppTopBar(
        title: folder.name,
        showBack: true,
        actions: [
          AppIconButton(
            icon: LucideIcons.moreVertical,
            tooltip: 'Folder options',
            onPressed: () => FolderActionsSheet.show(
              context,
              folder: folder,
              onDeletedFromScreen: () => Navigator.of(context).maybePop(),
            ),
          ),
        ],
      ),
      floatingActionButton: FabPill(
        onCamera: () => showAppToast(context, 'Scanning arrives in Phase 4'),
        onAdd: () => HomeAddSheet.show(context),
      ),
      body: CustomScrollView(
        slivers: [
          DocumentListSliver(folderId: folderId),
        ],
      ),
    );
  }
}
