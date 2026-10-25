import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/opencv_image_engine.dart';
import '../../domain/capture_mode.dart';
import '../../domain/scan_session.dart';
import 'arrange_screen.dart';
import 'review_actions_helper.dart';
import 'review_bottom_bar.dart';
import 'review_page_view.dart';
import 'review_screen_helper.dart';
import 'review_top_bar.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key, this.initialIndex});
  final int? initialIndex;

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  late final PageController _pageController;
  int _currentIndex = 0;
  bool _isColorOpen = false;
  final Map<String, Map<String, Uint8List>> _thumbnailsCache = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex ?? 0;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _fetchThumbnails(ScanSessionPage page) {
    if (_thumbnailsCache.containsKey(page.id)) return;
    ReviewActionsHelper.loadThumbnails(ref: ref, page: page).then((map) {
      if (mounted && map.isNotEmpty) {
        setState(() => _thumbnailsCache[page.id] = map);
      }
    });
  }

  Future<void> _onCrop(ScanSession session) async {
    await ReviewActionsHelper.cropPage(
      context: context,
      ref: ref,
      session: session,
      currentIndex: _currentIndex,
    );
    if (mounted) setState(() {});
  }

  Future<void> _onRotate(ScanSession session) async {
    await ReviewActionsHelper.rotatePage(
      ref: ref,
      session: session,
      currentIndex: _currentIndex,
    );
    if (mounted) setState(() {});
  }

  Future<void> _onDelete(ScanSession session) async {
    final nextIdx = await ReviewActionsHelper.deletePage(
      context: context,
      ref: ref,
      session: session,
      currentIndex: _currentIndex,
    );
    if (nextIdx != null && mounted) {
      setState(() => _currentIndex = nextIdx);
      if (_pageController.hasClients) _pageController.jumpToPage(_currentIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(scanSessionProvider);
    if (session.pages.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('No pages scanned')),
      );
    }
    final page = session.pages[_currentIndex.clamp(0, session.pages.length - 1)];
    if (_isColorOpen) _fetchThumbnails(page);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) ReviewScreenHelper.onBack(context, ref, session);
      },
      child: Scaffold(
        backgroundColor: AppColors.pageBackdrop,
        appBar: ReviewTopBar(
          title: session.name ?? 'docLoom Scan',
          onBack: () => ReviewScreenHelper.onBack(context, ref, session),
          onRename: () => ReviewScreenHelper.onRename(context, ref, session),
        ),
        body: ReviewPageView(
          controller: _pageController,
          pages: session.pages,
          currentIndex: _currentIndex,
          onPageChanged: (i) => setState(() => _currentIndex = i),
          engine: ref.read(engineProvider),
        ),
        bottomNavigationBar: ReviewBottomBar(
          isColorOpen: _isColorOpen,
          isCropVisible: page.mode != CaptureMode.idCard,
          selectedFilterId: page.filterId,
          thumbnails: _thumbnailsCache[page.id] ?? const {},
          onSelectFilter: (fid) => ReviewActionsHelper.selectFilter(
            ref: ref,
            session: session,
            currentIndex: _currentIndex,
            filterId: fid,
          ).then((_) => mounted ? setState(() {}) : null),
          onApplyToAll: () => ReviewActionsHelper.applyFilterToAll(
            ref: ref,
            session: session,
            currentIndex: _currentIndex,
          ).then((_) => mounted ? setState(() {}) : null),
          onCrop: () => _onCrop(session),
          onColor: () => setState(() => _isColorOpen = !_isColorOpen),
          onRotate: () => _onRotate(session),
          onArrange: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ArrangeScreen()),
          ),
          onRetake: () => ReviewScreenHelper.onRetake(context, ref, _currentIndex)
              .then((_) => mounted ? setState(() {}) : null),
          onDelete: () => _onDelete(session),
          onCheck: () => ReviewScreenHelper.onCheck(context, ref),
        ),
      ),
    );
  }
}
