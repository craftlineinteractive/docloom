import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/providers/home_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import 'folder_edit_dialog.dart';
import 'sort_dialog.dart';

class HomeOverflowMenu extends ConsumerWidget {
  const HomeOverflowMenu({super.key, this.isHome = true});

  final bool isHome;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sort = ref.watch(documentSortProvider);
    final viewMode = ref.watch(viewModeProvider);

    return PopupMenuButton<String>(
      icon: const Icon(LucideIcons.moreVertical, color: AppColors.textPrimary, size: 20),
      tooltip: 'More options',
      position: PopupMenuPosition.under,
      offset: const Offset(0, 4),
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 288),
      color: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 6,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: const BorderSide(color: AppColors.divider),
      ),
      onSelected: (action) {
        switch (action) {
          case 'sort':
            SortDialog.show(context);
          case 'select':
            ref.read(selectModeProvider.notifier).enter();
          case 'create_folder':
            FolderEditDialog.showCreate(context);
          case 'view_mode':
            final next = viewMode == ViewMode.list ? ViewMode.grid : ViewMode.list;
            ref.read(viewModeProvider.notifier).setMode(next);
            showAppToast(context, 'Switched to ${next == ViewMode.grid ? 'Grid' : 'List'} view');
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'sort',
          child: Row(
            children: [
              const Icon(LucideIcons.arrowUpDown, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.sm),
              const Text('Sort By', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  documentSortLabel(sort),
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'select',
          child: Row(
            children: [
              Icon(LucideIcons.checkSquare, size: 18, color: AppColors.textSecondary),
              SizedBox(width: AppSpacing.md),
              Text('Select', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        if (isHome)
          const PopupMenuItem<String>(
            value: 'create_folder',
            child: Row(
              children: [
                Icon(LucideIcons.folderPlus, size: 18, color: AppColors.textSecondary),
                SizedBox(width: AppSpacing.md),
                Text('Create Folder', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        PopupMenuItem<String>(
          value: 'view_mode',
          child: Row(
            children: [
              Icon(
                viewMode == ViewMode.list ? LucideIcons.layoutGrid : LucideIcons.list,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.md),
              const Text('View Mode', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.pageBackdrop,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  viewMode == ViewMode.list ? 'List' : 'Grid',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
