import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../application/camera_settings_provider.dart';
import '../application/scan_providers.dart';
import '../domain/camera_permission_service.dart';
import '../domain/camera_service.dart';
import '../domain/scan_gateway.dart';
import '../domain/scan_session.dart';
import 'camera_body.dart';
import 'camera_capture_coordinator.dart';
import 'camera_orientation_helper.dart';
import 'camera_permission_view.dart';
import 'camera_qr_coordinator.dart';
import 'review/review_dialogs.dart';
import 'scan_finish_coordinator.dart';
import 'widgets/camera_session_slots.dart';

part 'camera_screen_helper.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key, this.retakePageIndex});
  final int? retakePageIndex;
  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> with WidgetsBindingObserver {
  CameraPermissionState _perm = CameraPermissionState.notDetermined;
  bool _isCheckingPerm = true;
  bool _isInit = false, _hasErr = false, _isCap = false, _grid = false;
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

  Future<void> _checkPermission() async {
    final status = await ref.read(cameraPermissionServiceProvider).checkStatus();
    if (mounted) setState(() => _isCheckingPerm = false);
    _setPermission(status);
  }

  Future<void> _requestPermission() async =>
      _setPermission(await ref.read(cameraPermissionServiceProvider).requestPermission());

  void _setPermission(CameraPermissionState s) {
    if (mounted) setState(() => _perm = s);
    if (s == CameraPermissionState.granted) _initCamera();
  }

  Future<void> _initCamera() async {
    if (!mounted) return;
    setState(() { _isInit = true; _hasErr = false; });
    try {
      final cam = ref.read(cameraServiceProvider);
      await cam.initialize(lens: _lens);
      if (mounted) {
        setState(() => _isInit = false);
        CameraQrCoordinator.startIfActive(ref: ref, camera: cam);
      }
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
      onStart: () => mounted ? setState(() => _isCap = true) : null,
      onEnd: () => mounted ? setState(() => _isCap = false) : null,
    );
  }

  void _onTapPreview(TapDownDetails d, Size size) {
    setState(() => _focusPos = d.localPosition);
    final normX = (d.localPosition.dx / size.width).clamp(0.0, 1.0);
    final normY = (d.localPosition.dy / size.height).clamp(0.0, 1.0);
    ref.read(cameraServiceProvider).setFocusPoint(Offset(normX, normY));
  }

  Future<void> _onBack() => _CameraScreenHelper.handleBack(context, ref, widget.retakePageIndex);

  Future<void> _onFinishScan() async {
    final s = await ScanFinishCoordinator.finish(context: context, ref: ref);
    if (s != null && mounted) Navigator.of(context).pop(s);
  }

  void _flip() {
    _lens = _lens == CameraLens.back ? CameraLens.front : CameraLens.back;
    _initCamera();
  }

  void _toggleGrid() => setState(() => _grid = !_grid);
  void _dismissFocus() => setState(() => _focusPos = null);

  void _onCycleFlash() {
    final cam = ref.read(cameraServiceProvider);
    cam.setFlash(_CameraScreenHelper.nextFlash(cam.currentFlash));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => _CameraScreenHelper.buildRoot(
    state: this,
    stateView: _CameraScreenHelper.buildStateView(
      isCheckingPerm: _isCheckingPerm,
      perm: _perm,
      hasErr: _hasErr,
      onRequestPerm: _requestPermission,
      onOpenSettings: () => ref.read(cameraPermissionServiceProvider).openSettings(),
      onRetryInit: _initCamera,
      onBack: _onBack,
    ),
  );
}
