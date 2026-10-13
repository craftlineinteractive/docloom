import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/time/relative_time.dart';
import '../../../core/widgets/widgets.dart';
import '../../documents/domain/document_summary.dart';
import '../../home/presentation/widgets/document_actions_sheet.dart';
import '../../home/presentation/widgets/document_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounceTimer;
  List<DocumentSummary>? _results;
  bool _loading = false;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _results = null;
        _loading = false;
      });
      return;
    }
    setState(() => _loading = true);
    _debounceTimer = Timer(const Duration(milliseconds: 250), () async {
      final repo = ref.read(documentRepositoryProvider);
      final res = await repo.searchByName(query);
      if (mounted) setState(() { _results = res; _loading = false; });
    });
  }

  void _clear() {
    _debounceTimer?.cancel();
    _controller.clear();
    setState(() { _results = null; _loading = false; });
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_controller.text.trim().isEmpty || _results == null) {
      return const EmptyState(
        icon: LucideIcons.search,
        title: 'Search documents',
        body: 'Type a name to search through your documents.',
      );
    }
    if (_results!.isEmpty) {
      return const EmptyState(
        icon: LucideIcons.fileX2,
        title: 'No documents found',
        body: 'Try searching with a different name.',
      );
    }

    final clock = ref.watch(clockProvider);
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.screenH),
      itemCount: _results!.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final doc = _results![index];
        final pageText = '${doc.pageCount} ${doc.pageCount == 1 ? 'page' : 'pages'}';
        return DocumentCard(
          key: ValueKey(doc.document.id),
          item: DocumentItem(
            name: doc.document.name,
            date: relativeTime(doc.document.updatedAt, clock()),
            pageCount: pageText,
            coverPath: doc.coverPath,
            isFavorite: doc.document.isFavorite,
            folderName: doc.folderName,
          ),
          onTap: () => showAppToast(context, 'Viewer comes in a later phase'),
          onOptionsPressed: () => DocumentActionsSheet.show(context, document: doc.document),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppIconButton(
          icon: LucideIcons.arrowLeft,
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: AppTextField(
          controller: _controller,
          hint: 'Search documents...',
          autofocus: true,
          onChanged: _onChanged,
          prefixIcon: const Icon(LucideIcons.search, size: 18, color: AppColors.textSecondary),
          suffixIcon: _controller.text.isNotEmpty
              ? AppIconButton(icon: LucideIcons.x, tooltip: 'Clear', onPressed: _clear)
              : null,
        ),
        titleSpacing: 0,
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: _buildBody(context),
    );
  }
}
