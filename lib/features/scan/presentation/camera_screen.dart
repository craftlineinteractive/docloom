import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../application/camera_settings_provider.dart';
import '../application/scan_providers.dart';
import '../application/scanner_controller_provider.dart';
import '../domain/camera_permission_service.dart';
import '../domain/camera_service.dart';
import '../domain/quad.dart';
import '../domain/scan_gateway.dart';
import '../domain/scan_session.dart';
import 'camera_body.dart';
import 'camera_capture_coordinator.dart';
import 'camera_init_coordinator.dart';
import 'camera_orientation_helper.dart';
import 'camera_permission_view.dart';
import 'camera_qr_coordinator.dart';
import 'review/review_dialogs.dart';
import 'scan_finish_coordinator.dart';
import 'widgets/camera_session_slots.dart';

part 'camera_screen_helper.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key, this.retakePageIndex, this.initialLiveQuad, this.initialLiveQuadTime});
  final int? retakePageIndex;
  final Quad? initialLiveQuad;
  final DateTime? initialLiveQuadTime;
  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> with WidgetsBindingObserver {
  late CameraService _camera;
  CameraPermissionState _perm = CameraPermissionState.notDetermined;
  bool _isCheckingPerm = true, _isInit = false, _hasErr = false, _isCap = false, _grid = false;
  Offset? _focusPos;
  CameraLens _lens = CameraLens.back;
  Quad? _liveQuad;
  DateTime? _liveQuadTime;

  @override
  void initState() {
    super.initState();
    _camera = ref.read(cameraServiceProvider);
    _resetFlags();
    _liveQuad = widget.initialLiveQuad;
    _liveQuadTime = widget.initialLiveQuadTime ?? (widget.initialLiveQuad != null ? DateTime.now() : null);
    if (kDebugMode) debugPrint('[scan] [6] route push');
    WidgetsBinding.instance.addObserver(this); CameraOrientationHelper.lockPortrait();
    _checkPermission();
  }

  @override
  void dispose() {
    if (kDebugMode) debugPrint('[scan] [6] route pop');
    _resetFlags(); CameraInitCoordinator.stopWatchdog();
    CameraInitCoordinator.dispose(camera: _camera);
    WidgetsBinding.instance.removeObserver(this);
    CameraOrientationHelper.restoreOrientations();
    super.dispose();
  }

  void _resetFlags() { _isInit = false; _isCap = false; _hasErr = false; _grid = false; _focusPos = null; }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) async {
    if (s == AppLifecycleState.resumed) {
      final p = await ref.read(cameraPermissionServiceProvider).checkStatus();
      if (!mounted) return;
      setState(() { _isCheckingPerm = false; _perm = p; });
      if (p != CameraPermissionState.granted) return;
    }
    CameraInitCoordinator.handleLifecycle(state: s, camera: _camera, onReinit: _initCamera, onStartWatchdog: _startWatchdog);
  }

  void _startWatchdog({bool resetStall = false}) => CameraInitCoordinator.startWatchdog(
    camera: _camera, onReinit: _initCamera, resetStall: resetStall,
    onStallExceeded: () => mounted ? setState(() => _hasErr = true) : null,
    isEligible: () => mounted && !_isInit && !_hasErr && _perm == CameraPermissionState.granted,
  );

  Future<void> _checkPermission() async {
    final s = await ref.read(cameraPermissionServiceProvider).checkStatus();
    if (mounted) setState(() { _isCheckingPerm = false; _perm = s; });
    if (s == CameraPermissionState.granted) _initCamera();
  }

  Future<void> _requestPermission() async {
    final s = await ref.read(cameraPermissionServiceProvider).requestPermission();
    if (mounted) setState(() => _perm = s);
    if (s == CameraPermissionState.granted) _initCamera();
  }

  Future<void> _initCamera() async {
    if (!mounted) return;
    setState(() { _isInit = true; _hasErr = false; });
    try {
      final sc = ref.read(betterScannerControllerProvider);
      final ok = await CameraInitCoordinator.initialize(
        camera: _camera, lens: _lens, onScannerInit: sc != null ? () => sc.initialize() : null, isMounted: () => mounted,
      );
      if (ok && mounted) {
        setState(() => _isInit = false);
        CameraQrCoordinator.startIfActive(ref: ref, camera: _camera);
        _startWatchdog();
      }
    } catch (_) {
      if (mounted) setState(() { _isInit = false; _hasErr = true; });
    }
  }

  Future<void> _onCapture() async {
    if (_isCap || _isInit || _hasErr) return;
    await CameraCaptureCoordinator.performCapture(
      context: context, ref: ref, camera: _camera, scannerController: ref.read(betterScannerControllerProvider),
      retakePageIndex: widget.retakePageIndex, liveQuad: _liveQuad, liveQuadTime: _liveQuadTime,
      onStart: () => mounted ? setState(() => _isCap = true) : null, onEnd: () => mounted ? setState(() => _isCap = false) : null,
    );
  }

  void _onTapPreview(TapDownDetails d, Size s) {
    setState(() => _focusPos = d.localPosition);
    _camera.setFocusPoint(Offset((d.localPosition.dx / s.width).clamp(0.0, 1.0), (d.localPosition.dy / s.height).clamp(0.0, 1.0)));
  }

  Future<void> _onBack() => _CameraScreenHelper.handleBack(context, ref, widget.retakePageIndex);
  Future<void> _onFinishScan() async {
    final s = await ScanFinishCoordinator.finish(context: context, ref: ref);
    if (s != null && mounted) Navigator.of(context).pop(s);
  }
  void _flip() { ref.read(betterScannerControllerProvider)?.switchCamera(); _lens = _lens == CameraLens.back ? CameraLens.front : CameraLens.back; _initCamera(); }
  void _toggleGrid() { ref.read(betterScannerControllerProvider)?.toggleGrid(); setState(() => _grid = !_grid); }
  void _dismissFocus() => setState(() => _focusPos = null);
  void _onCycleFlash() { ref.read(betterScannerControllerProvider)?.cycleFlashMode(); _camera.setFlash(_CameraScreenHelper.nextFlash(_camera.currentFlash)); setState(() {}); }

  @override
  Widget build(BuildContext context) => _CameraScreenHelper.buildRoot(
    state: this,
    stateView: _CameraScreenHelper.buildStateView(
      isCheckingPerm: _isCheckingPerm, perm: _perm, hasErr: _hasErr, onRequestPerm: _requestPermission,
      onOpenSettings: () => ref.read(cameraPermissionServiceProvider).openSettings(),
      onRetryInit: () { _startWatchdog(resetStall: true); _initCamera(); }, onBack: _onBack,
    ),
  );
}
