import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import '../../../../core/constants/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_progress_dialog.dart';
import '../../data/opencv_image_engine.dart';
import '../../domain/quad.dart';
import 'adjust_bottom_bar.dart';
import 'adjust_crop_container.dart';
import 'adjust_filter_row.dart';
import 'adjust_result.dart';
import 'adjust_tools_row.dart';
import 'adjust_top_bar.dart';
import 'crop_editor.dart';
import 'filter_bottom_sheet.dart';

const SystemUiOverlayStyle _overlay = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
);

class AdjustScreen extends ConsumerStatefulWidget {
  const AdjustScreen({
    super.key,
    required this.previewPath,
    required this.importedPath,
    this.rawCapturePath,
    this.initialQuad,
    this.initialRotation = 0,
    this.initialFilterId,
    this.pageIndicator = '1/1',
  });

  final String previewPath, importedPath;
  final String? rawCapturePath, initialFilterId;
  final Quad? initialQuad;
  final int initialRotation;
  final String pageIndicator;

  @override
  ConsumerState<AdjustScreen> createState() => _AdjustScreenState();
}

class _AdjustScreenState extends ConsumerState<AdjustScreen> {
  late Quad _quad; late int _rotation; late String _filterId;
  Uint8List? _previewBytes;

  @override
  void initState() {
    super.initState();
    _quad = widget.initialQuad ?? Quad.defaultInset();
    _rotation = widget.initialRotation;
    _filterId = widget.initialFilterId ?? AppConfig.defaultFilterId;
    _updatePreviewBytes(_filterId);
  }

  void _rotate() => setState(() {
        _rotation = (_rotation + 90) % 360;
        _quad = _quad.rotated90();
      });
  void _reset() => setState(() => _quad = Quad.defaultInset());

  Future<void> _updatePreviewBytes(String filterId) async {
    setState(() => _filterId = filterId);
    if (filterId == 'original') {
      if (mounted) setState(() => _previewBytes = null);
      return;
    }
    try {
      final b = await ref.read(engineProvider).renderPreview(
            previewPath: widget.previewPath, quad: Quad.unit(), rotation: 0, filterId: filterId);
      if (mounted) setState(() => _previewBytes = b);
    } catch (_) {}
  }

  void _openFilterSheet() => showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
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
    final dir = Directory(widget.importedPath).parent.path;
    final dst = p.join(dir, 'rendered_${DateTime.now().millisecondsSinceEpoch}.jpg');
    final res = await showAppProgressDialog<String>(
      context: context,
      message: 'Processing document...',
      task: () => ref.read(engineProvider).renderPage(
            srcPath: widget.importedPath, quad: _quad,
            rotation: _rotation, filterId: _filterId, dstPath: dst,
          ),
    );
    if (mounted) {
      Navigator.of(context).pop(AdjustResult(
        renderedPath: res, quad: _quad, rotation: _rotation, filterId: _filterId,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _overlay,
      child: Scaffold(
        backgroundColor: AppColors.cameraBlack,
        body: SafeArea(
          child: Column(
            children: [
              AdjustTopBar(onBack: () => Navigator.of(context).pop(null), pageIndicator: widget.pageIndicator),
              AdjustCropContainer(
                rotation: _rotation,
                child: CropEditor(
                  previewPath: widget.importedPath,
                  previewBytes: _previewBytes,
                  quad: _quad,
                  onChanged: (q) => setState(() => _quad = q),
                ),
              ),
              const AdjustHintText(),
              AdjustFilterRow(currentFilterId: _filterId, onTapFilter: _openFilterSheet),
              AdjustToolsRow(onRotate: _rotate, onReset: _reset),
              AdjustBottomBar(onRetake: _retake, onContinue: _continue),
            ],
          ),
        ),
      ),
    );
  }
}
