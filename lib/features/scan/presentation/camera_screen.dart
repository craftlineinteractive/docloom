import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/widgets/app_toast.dart';
import '../application/scan_providers.dart';
import '../data/opencv_image_engine.dart';
import '../domain/camera_permission_service.dart';
import '../domain/camera_service.dart';
import '../domain/scan_gateway.dart';
import 'camera_body.dart';
import 'camera_capture_helper.dart';
import 'camera_orientation_helper.dart';
import 'camera_permission_view.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen>
    with WidgetsBindingObserver {
  final _sessionId = const Uuid().v4();
  CameraPermissionState _permission = CameraPermissionState.notDetermined;
  bool _isInit = false, _hasError = false, _isCapturing = false;
  bool _isGrid = false, _showFlash = false;
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      ref.read(cameraServiceProvider).dispose();
    } else if (state == AppLifecycleState.resumed) {
      _checkPermission();
    }
  }

  Future<void> _checkPermission() async {
    final s = await ref.read(cameraPermissionServiceProvider).checkStatus();
    _setPermission(s);
  }

  Future<void> _requestPermission() async {
    final s = await ref.read(cameraPermissionServiceProvider).requestPermission();
    _setPermission(s);
  }

  void _setPermission(CameraPermissionState s) {
    if (!mounted) return;
    setState(() => _permission = s);
    if (s == CameraPermissionState.granted) _initCamera();
  }

  Future<void> _initCamera() async {
    if (!mounted) return;
    setState(() { _isInit = true; _hasError = false; });
    try {
      await ref.read(cameraServiceProvider).initialize(lens: _lens);
      if (mounted) setState(() => _isInit = false);
    } catch (_) {
      if (mounted) setState(() { _isInit = false; _hasError = true; });
    }
  }

  Future<void> _onCapture() async {
    if (_isCapturing || _isInit || _hasError) return;
    setState(() => _isCapturing = true);
    try {
      await CameraCaptureHelper.captureAndProcess(
        context: context,
        camera: ref.read(cameraServiceProvider),
        engine: ref.read(engineProvider),
        sessionId: _sessionId,
        onCaptured: () { if (mounted) setState(() => _isCapturing = false); },
      );
    } catch (_) {
      showAppToastGlobal('Capture failed. Please try again.');
    } finally {
      if (mounted && _isCapturing) setState(() => _isCapturing = false);
    }
  }

  void _onTapPreview(TapDownDetails d, Size size) {
    setState(() => _focusPos = d.localPosition);
    final norm = Offset((d.localPosition.dx / size.width).clamp(0.0, 1.0),
        (d.localPosition.dy / size.height).clamp(0.0, 1.0));
    ref.read(cameraServiceProvider).setFocusPoint(norm);
  }

  void _onBack() => Navigator.of(context).pop(const ScanCancelled());

  @override
  Widget build(BuildContext context) {
    if (_permission != CameraPermissionState.granted) {
      return CameraPermissionView(
        state: _permission,
        onRequest: _requestPermission,
        onOpenSettings: () => ref.read(cameraPermissionServiceProvider).openSettings(),
        onBack: _onBack,
      );
    }
    if (_hasError) return CameraErrorView(onRetry: _initCamera, onBack: _onBack);
    final camera = ref.read(cameraServiceProvider);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) { if (!didPop) _onBack(); },
      child: CameraBody(
        camera: camera,
        isGridVisible: _isGrid,
        showFlashMenu: _showFlash,
        focusPos: _focusPos,
        isInitializing: _isInit,
        isCapturing: _isCapturing,
        onBack: _onBack,
        onToggleFlashMenu: () => setState(() => _showFlash = !_showFlash),
        onToggleGrid: () => setState(() => _isGrid = !_isGrid),
        onFlipCamera: () {
          _lens = _lens == CameraLens.back ? CameraLens.front : CameraLens.back;
          _initCamera();
        },
        onSelectFlash: (flash) {
          camera.setFlash(flash);
          setState(() => _showFlash = false);
        },
        onTapPreview: _onTapPreview,
        onDismissFocus: () => setState(() => _focusPos = null),
        onCapture: _onCapture,
      ),
    );
  }
}
