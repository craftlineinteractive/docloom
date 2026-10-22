import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../application/scan_providers.dart';
import '../../data/opencv_edge_detector.dart';
import '../../data/opencv_image_engine.dart';
import '../../domain/aspect_crop_helper.dart';
import '../../domain/capture_mode.dart';
import '../../domain/photo_size.dart';
import '../../domain/quad.dart';
import '../../application/capture_mode_provider.dart';
import 'adjust_bottom_bar.dart';
import 'adjust_crop_container.dart';
import 'adjust_editor_content.dart';
import 'adjust_filter_row.dart';
import 'adjust_render_helper.dart';
import 'adjust_tools_row.dart';
import 'adjust_top_bar.dart';
import 'filter_bottom_sheet.dart';

const _overlay = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
);

class AdjustScreen extends ConsumerStatefulWidget {
  const AdjustScreen({
    super.key, required this.previewPath, required this.importedPath,
    this.rawCapturePath, this.initialQuad, this.initialRotation = 0,
    this.initialFilterId, this.pageIndicator = '1/1',
    this.mode = CaptureMode.document, this.photoSize, this.bookScanType,
  });

  final String previewPath, importedPath;
  final String? rawCapturePath, initialFilterId;
  final Quad? initialQuad;
  final int initialRotation;
  final String pageIndicator;
  final CaptureMode mode;
  final PhotoSize? photoSize;
  final BookScanType? bookScanType;

  @override
  ConsumerState<AdjustScreen> createState() => _AdjustScreenState();
}

class _AdjustScreenState extends ConsumerState<AdjustScreen> {
  late Quad _quad; late int _rotation; late String _filterId;
  Uint8List? _previewBytes;
  bool _isDetecting = false;
  double _splitRatio = 0.5;

  @override
  void initState() {
    super.initState();
    if (widget.mode == CaptureMode.photo && widget.photoSize != null) {
      final p = widget.photoSize!.pixelSize;
      _quad = widget.initialQuad ??
          AspectCropHelper.rectToQuad(AspectCropHelper.initialRect(targetAR: p.width / p.height, imageAR: 3 / 4));
    } else {
      _quad = widget.initialQuad ?? Quad.defaultInset();
    }
    _rotation = widget.initialRotation;
    _filterId = widget.initialFilterId ?? AppConfig.defaultFilterId;
    _updatePreviewBytes(_filterId);
    if (widget.initialQuad == null && widget.mode.autoDetect) _autoDetect(isInitial: true);
  }

  Future<void> _autoDetect({bool isInitial = false}) async {
    if (isInitial && !ref.read(autoCropEnabledProvider)) return;
    if (_isDetecting) return;
    if (mounted) setState(() => _isDetecting = true);
    try {
      final q = await ref.read(edgeDetectorProvider).detectFromFile(widget.previewPath);
      if (q != null && mounted) setState(() => _quad = q);
    } catch (_) {}
    if (mounted) setState(() => _isDetecting = false);
  }

  void _rotate() => setState(() { _rotation = (_rotation + 90) % 360; _quad = _quad.rotated90(); });
  void _reset() => setState(() => _quad = Quad.defaultInset());

  Future<void> _updatePreviewBytes(String filterId) async {
    setState(() => _filterId = filterId);
    if (filterId == 'original') { if (mounted) setState(() => _previewBytes = null); return; }
    try {
      final b = await ref.read(engineProvider).renderPreview(
            previewPath: widget.previewPath, quad: Quad.unit(), rotation: 0, filterId: filterId);
      if (mounted) setState(() => _previewBytes = b);
    } catch (_) {}
  }

  void _openFilterSheet() => showModalBottomSheet<void>(
        context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
        builder: (_) => FilterBottomSheet(
          previewPath: widget.previewPath, quad: _quad, rotation: _rotation,
          selectedFilterId: _filterId, onSelectFilter: _updatePreviewBytes,
        ),
      );

  void _retake() {
    for (final p in [widget.rawCapturePath, widget.importedPath, widget.previewPath]) {
      if (p != null) try { File(p).deleteSync(); } catch (_) {}
    }
    Navigator.of(context).pop(null);
  }

  Future<void> _continue() async {
    final res = await AdjustRenderHelper.processContinue(
      context: context, ref: ref, importedPath: widget.importedPath, quad: _quad,
      rotation: _rotation, filterId: _filterId, mode: widget.mode, photoSize: widget.photoSize,
      bookScanType: widget.bookScanType, splitRatio: _splitRatio,
    );
    if (res != null && mounted) Navigator.of(context).pop(res);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _overlay,
      child: Scaffold(
        backgroundColor: AppColors.cameraBlack,
        body: SafeArea(
          child: Column(children: [
            AdjustTopBar(onBack: () => Navigator.of(context).pop(null), pageIndicator: widget.pageIndicator),
            AdjustCropContainer(
              rotation: _rotation,
              child: AdjustEditorContent(
                mode: widget.mode, importedPath: widget.importedPath,
                previewBytes: _previewBytes, quad: _quad,
                onQuadChanged: (q) => setState(() => _quad = q),
                splitRatio: _splitRatio, onSplitChanged: (r) => setState(() => _splitRatio = r),
                photoSize: widget.photoSize, bookScanType: widget.bookScanType,
              ),
            ),
            const AdjustHintText(),
            AdjustFilterRow(currentFilterId: _filterId, onTapFilter: _openFilterSheet),
            AdjustToolsRow(onRotate: _rotate, onReset: _reset, onAutoDetect: _autoDetect, isDetecting: _isDetecting),
            AdjustBottomBar(onRetake: _retake, onContinue: _continue),
          ]),
        ),
      ),
    );
  }
}
