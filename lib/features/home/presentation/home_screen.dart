import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import 'widgets/document_card.dart';
import 'widgets/folder_card.dart';

const _sampleFolders = [
  FolderItem(
    name: 'Client Files',
    itemCountAndDate: '4 items - 12 Oct',
    color: AppColors.folderIndigo,
  ),
  FolderItem(
    name: 'Property Documents',
    itemCountAndDate: '8 items - 04 Oct',
    color: AppColors.folderOrange,
  ),
  FolderItem(
    name: 'Personal IDs',
    itemCountAndDate: '3 items - 28 Sep',
    color: AppColors.folderGreen,
  ),
];

const _sampleDocuments = [
  DocumentItem(
    name: 'sunilkumar_prajapati',
    date: '2 days ago',
    pageCount: '26 pages',
  ),
  DocumentItem(
    name: 'DocLoom 17 Sept 2026 12-02',
    date: '3 weeks ago',
    pageCount: '1 page',
  ),
  DocumentItem(
    name: 'kunjbhai',
    date: '30 Jul 2026',
    pageCount: '39 pages',
  ),
  DocumentItem(
    name: 'pravinaben',
    date: '30 Jul 2026',
    pageCount: '16 pages',
  ),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        title: 'docLoom',
        leading: AppIconButton(
          icon: LucideIcons.menu,
          tooltip: 'Menu',
          onPressed: () {},
        ),
        actions: [
          AppIconButton(
            icon: LucideIcons.crown,
            tooltip: 'Upgrade to PRO',
            color: AppColors.gold,
            onPressed: () {},
          ),
          AppIconButton(
            icon: LucideIcons.search,
            tooltip: 'Search documents',
            onPressed: () {},
          ),
          AppIconButton(
            icon: LucideIcons.moreVertical,
            tooltip: 'More options',
            onPressed: () {},
          ),
          if (kDebugMode)
            AppIconButton(
              icon: LucideIcons.layoutGrid,
              tooltip: 'Component Gallery',
              onPressed: () => context.push(Routes.gallery),
            ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(
              left: AppSpacing.screenH,
              right: AppSpacing.screenH,
              top: AppSpacing.md,
              bottom: AppSpacing.xxl * 4,
            ),
            children: [
              const SectionHeader(title: 'Folders', count: 3),
              const SizedBox(height: AppSpacing.sm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < _sampleFolders.length; i++) ...[
                    if (i > 0) const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: FolderCard(item: _sampleFolders[i]),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              const SectionHeader(title: 'Documents', count: 4),
              const SizedBox(height: AppSpacing.sm),
              for (final doc in _sampleDocuments) ...[
                DocumentCard(item: doc),
                const SizedBox(height: AppSpacing.md),
              ],
            ],
          ),
          Positioned(
            right: AppSpacing.screenH,
            bottom: AppSpacing.xxl,
            child: FabPill(
              onCamera: () => showAppToast(context, 'Camera coming soon'),
              onAdd: () => showAppToast(context, 'Import coming soon'),
            ),
          ),
        ],
      ),
    );
  }
}
