import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../app/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/time/relative_time.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../folders/domain/folder_summary.dart';
import 'folder_actions_sheet.dart';
import 'folder_card.dart';
import 'folder_edit_dialog.dart';

class FoldersSectionSliver extends StatelessWidget {
  const FoldersSectionSliver({super.key, required this.folders});

  final List<FolderSummary> folders;

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
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
        ] else
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
      ],
    );
  }
}
