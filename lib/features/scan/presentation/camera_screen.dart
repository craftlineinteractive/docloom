import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/scan_providers.dart';
import '../domain/camera_permission_service.dart';
import '../domain/camera_service.dart';
import '../domain/scan_gateway.dart';
import '../domain/scan_session.dart';
import 'camera_body.dart';
import 'camera_capture_coordinator.dart';
import 'camera_orientation_helper.dart';
import 'camera_permission_view.dart';
import 'review/review_dialogs.dart';
import 'widgets/camera_session_slots.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key, this.retakePageIndex});
  final int? retakePageIndex;

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> with WidgetsBindingObserver {
  CameraPermissionState _perm = CameraPermissionState.notDetermined;
  bool _isInit = false, _hasErr = false, _isCap = false, _grid = false, _flash = false;
  Offset? _focusPos;
  CameraLens _lens = CameraLens.back;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    CameraOrientationHelper.lockPortrait();
    _checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    CameraOrientationHelper.restoreOrientations();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if (s == AppLifecycleState.inactive || s == AppLifecycleState.paused) {
      ref.read(cameraServiceProvider).dispose();
    } else if (s == AppLifecycleState.resumed) {
      _checkPermission();
    }
  }

  Future<void> _checkPermission() async => _setPermission(await ref.read(cameraPermissionServiceProvider).checkStatus());
  Future<void> _requestPermission() async => _setPermission(await ref.read(cameraPermissionServiceProvider).requestPermission());

  void _setPermission(CameraPermissionState s) {
    if (!mounted) return;
    setState(() => _perm = s);
    if (s == CameraPermissionState.granted) _initCamera();
  }

  Future<void> _initCamera() async {
    if (!mounted) return;
    setState(() { _isInit = true; _hasErr = false; });
    try {
      await ref.read(cameraServiceProvider).initialize(lens: _lens);
      if (mounted) setState(() => _isInit = false);
    } catch (_) {
      if (mounted) setState(() { _isInit = false; _hasErr = true; });
    }
  }

  Future<void> _onCapture() async {
    if (_isCap || _isInit || _hasErr) return;
    await CameraCaptureCoordinator.performCapture(
      context: context,
      ref: ref,
      camera: ref.read(cameraServiceProvider),
      retakePageIndex: widget.retakePageIndex,
      onStart: () { if (mounted) setState(() => _isCap = true); },
      onEnd: () { if (mounted) setState(() => _isCap = false); },
    );
  }

  void _onTapPreview(TapDownDetails d, Size size) {
    setState(() => _focusPos = d.localPosition);
    ref.read(cameraServiceProvider).setFocusPoint(Offset(
      (d.localPosition.dx / size.width).clamp(0.0, 1.0),
      (d.localPosition.dy / size.height).clamp(0.0, 1.0),
    ));
  }

  Future<void> _onBack() async {
    if (widget.retakePageIndex != null) { Navigator.of(context).pop(null); return; }
    final session = ref.read(scanSessionProvider);
    if (session.pages.isNotEmpty) {
      if (await ReviewDialogs.showDiscardScanDialog(context, session.pages.length) && mounted) {
        ref.read(scanSessionProvider.notifier).discard();
        Navigator.of(context).pop(const ScanCancelled());
      }
    } else {
      Navigator.of(context).pop(const ScanCancelled());
    }
  }

  void _flip() {
    _lens = _lens == CameraLens.back ? CameraLens.front : CameraLens.back;
    _initCamera();
  }

  @override
  Widget build(BuildContext context) {
    if (_perm != CameraPermissionState.granted) {
      return CameraPermissionView(
        state: _perm,
        onRequest: _requestPermission,
        onOpenSettings: () => ref.read(cameraPermissionServiceProvider).openSettings(),
        onBack: _onBack,
      );
    }
    if (_hasErr) return CameraErrorView(onRetry: _initCamera, onBack: _onBack);
    final session = ref.watch(scanSessionProvider);
    final isRetake = widget.retakePageIndex != null;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) { if (!didPop) _onBack(); },
      child: CameraBody(
        camera: ref.read(cameraServiceProvider),
        isGridVisible: _grid,
        showFlashMenu: _flash,
        focusPos: _focusPos,
        isInitializing: _isInit,
        isCapturing: _isCap,
        leftSlot: CameraSlotsHelper.buildLeft(context: context, session: session, isRetake: isRetake),
        rightSlot: CameraSlotsHelper.buildRight(context: context, session: session, isRetake: isRetake),
        onBack: _onBack,
        onToggleFlashMenu: () => setState(() => _flash = !_flash),
        onToggleGrid: () => setState(() => _grid = !_grid),
        onFlipCamera: _flip,
        onSelectFlash: (f) { ref.read(cameraServiceProvider).setFlash(f); setState(() => _flash = false); },
        onTapPreview: _onTapPreview,
        onDismissFocus: () => setState(() => _focusPos = null),
        onCapture: _onCapture,
      ),
    );
  }
}
