import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/opencv_image_engine.dart';
import '../../domain/capture_mode.dart';
import '../../domain/scan_session.dart';
import '../camera_screen.dart';
import 'arrange_screen.dart';
import 'review_actions_helper.dart';
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
  late final PageController _pageController;
  int _currentIndex = 0;
  bool _isColorOpen = false;

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

  Future<void> _onCrop(ScanSession session) async {
    await ReviewActionsHelper.cropPage(
      context: context, ref: ref, session: session, currentIndex: _currentIndex,
    );
    if (mounted) setState(() {});
  }

  Future<void> _onRotate(ScanSession session) async {
    await ReviewActionsHelper.rotatePage(ref: ref, session: session, currentIndex: _currentIndex);
    if (mounted) setState(() {});
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
    final nextIdx = await ReviewActionsHelper.deletePage(
      context: context, ref: ref, session: session, currentIndex: _currentIndex,
    );
    if (nextIdx != null && mounted) {
      setState(() => _currentIndex = nextIdx);
      if (_pageController.hasClients) _pageController.jumpToPage(_currentIndex);
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
        isCropVisible: page.mode != CaptureMode.idCard,
        selectedFilterId: page.filterId,
        onSelectFilter: (fid) async {
          await ReviewActionsHelper.selectFilter(ref: ref, session: session, currentIndex: _currentIndex, filterId: fid);
          if (mounted) setState(() {});
        },
        onApplyToAll: () async {
          await ReviewActionsHelper.applyFilterToAll(ref: ref, session: session, currentIndex: _currentIndex);
          if (mounted) setState(() {});
        },
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
