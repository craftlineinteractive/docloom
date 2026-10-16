import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/opencv_image_engine.dart';
import '../../domain/scan_session.dart';
import '../adjust/adjust_result.dart';
import '../adjust/adjust_screen.dart';
import '../camera_screen.dart';
import 'arrange_screen.dart';
import 'review_bottom_bar.dart';
import 'review_dialogs.dart';
import 'review_page_view.dart';
import 'review_top_bar.dart';

import '../scan_finish_coordinator.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key, this.initialIndex});
  final int? initialIndex;

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  late int _currentIndex;
  late PageController _pageController;
  bool _isColorOpen = false;

  @override
  void initState() {
    super.initState();
    final c = ref.read(scanSessionProvider).pages.length;
    _currentIndex = (widget.initialIndex ?? (c > 0 ? c - 1 : 0)).clamp(0, c > 0 ? c - 1 : 0);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onCrop(ScanSession session) async {
    final page = session.pages[_currentIndex];
    final res = await Navigator.of(context).push<AdjustResult>(
      MaterialPageRoute(
        builder: (_) => AdjustScreen(
          previewPath: page.previewPath, importedPath: page.capturePath,
          rawCapturePath: page.capturePath, initialQuad: page.quad,
          initialRotation: page.rotation, initialFilterId: page.filterId,
          pageIndicator: '${_currentIndex + 1}/${session.pages.length}',
        ),
      ),
    );
    if (res != null && mounted) {
      final n = ref.read(scanSessionProvider.notifier);
      n.updateCrop(_currentIndex, res.quad);
      n.setRotation(_currentIndex, res.rotation);
      n.setFilter(_currentIndex, res.filterId);
      setState(() {});
    }
  }

  void _onRotate(ScanSession session) {
    final p = session.pages[_currentIndex];
    ref.read(scanSessionProvider.notifier).setRotation(_currentIndex, (p.rotation + 90) % 360);
    setState(() {});
  }

  Future<void> _onRetake() async {
    final newPage = await Navigator.of(context).push<ScanSessionPage>(
      MaterialPageRoute(builder: (_) => CameraScreen(retakePageIndex: _currentIndex)),
    );
    if (newPage != null && mounted) {
      ref.read(scanSessionProvider.notifier).replacePage(_currentIndex, newPage);
      setState(() {});
    }
  }

  Future<void> _onDelete(ScanSession session) async {
    if (session.pages.length > 1) {
      if (await ReviewDialogs.showDeletePageDialog(context, _currentIndex + 1) && mounted) {
        ref.read(scanSessionProvider.notifier).removePage(_currentIndex);
        final len = ref.read(scanSessionProvider).pages.length;
        setState(() => _currentIndex = _currentIndex.clamp(0, len - 1));
        if (_pageController.hasClients) _pageController.jumpToPage(_currentIndex);
      }
    } else if (await ReviewDialogs.showDiscardScanDialog(context, 1) && mounted) {
      ref.read(scanSessionProvider.notifier).discard();
      Navigator.of(context).pop();
    }
  }

  Future<void> _onRename(ScanSession session) async {
    final name = await ReviewDialogs.showRenameScanDialog(context, session.name ?? 'docLoom Scan');
    if (name != null && name.isNotEmpty && mounted) {
      ref.read(scanSessionProvider.notifier).setName(name);
    }
  }

  Future<void> _onCheck() async {
    final success = await ScanFinishCoordinator.finish(context: context, ref: ref);
    if (success != null && mounted) Navigator.of(context).pop(success);
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(scanSessionProvider);
    if (session.pages.isEmpty) {
      return const Scaffold(backgroundColor: AppColors.background, body: Center(child: Text('No pages scanned')));
    }
    final page = session.pages[_currentIndex.clamp(0, session.pages.length - 1)];

    return Scaffold(
      backgroundColor: AppColors.pageBackdrop,
      appBar: ReviewTopBar(
        title: session.name ?? 'docLoom Scan',
        onBack: () => Navigator.of(context).pop(),
        onRename: () => _onRename(session),
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
        selectedFilterId: page.filterId,
        onSelectFilter: (fid) => setState(() => ref.read(scanSessionProvider.notifier).setFilter(_currentIndex, fid)),
        onApplyToAll: () => setState(() => ref.read(scanSessionProvider.notifier).setFilterForAll(page.filterId)),
        onCrop: () => _onCrop(session),
        onColor: () => setState(() => _isColorOpen = !_isColorOpen),
        onRotate: () => _onRotate(session),
        onArrange: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ArrangeScreen())),
        onRetake: _onRetake,
        onDelete: () => _onDelete(session),
        onCheck: _onCheck,
      ),
    );
  }
}
