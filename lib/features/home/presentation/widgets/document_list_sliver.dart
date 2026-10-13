import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/providers/home_providers.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/time/relative_time.dart';
import '../../../../core/widgets/widgets.dart';
import 'document_actions_sheet.dart';
import 'document_card.dart';

class DocumentListSliver extends ConsumerWidget {
  const DocumentListSliver({super.key, this.folderId});

  final String? folderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(documentsProvider(folderId));
    final clock = ref.watch(clockProvider);
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
          sliver: SliverList.separated(
            itemCount: docs.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final pageCount = '${doc.pageCount} ${doc.pageCount == 1 ? 'page' : 'pages'}';
              return DocumentCard(
                key: ValueKey(doc.document.id),
                item: DocumentItem(
                  name: doc.document.name,
                  date: relativeTime(doc.document.updatedAt, clock()),
                  pageCount: pageCount,
                  coverPath: doc.coverPath,
                  isFavorite: doc.document.isFavorite,
                ),
                onTap: () => showAppToast(context, 'Viewer comes in a later phase'),
                onOptionsPressed: () => DocumentActionsSheet.show(context, document: doc.document),
              );
            },
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}
