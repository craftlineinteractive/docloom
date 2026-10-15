import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
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

class AdjustScreen extends ConsumerStatefulWidget {
  const AdjustScreen({
    super.key,
    required this.previewPath,
    required this.importedPath,
    this.rawCapturePath,
    this.initialQuad,
    this.pageIndicator = '1/1',
  });

  final String previewPath, importedPath;
  final String? rawCapturePath;
  final Quad? initialQuad;
  final String pageIndicator;

  @override
  ConsumerState<AdjustScreen> createState() => _AdjustScreenState();
}

class _AdjustScreenState extends ConsumerState<AdjustScreen> {
  late Quad _quad;
  int _rotation = 0;
  String _filterId = AppConfig.defaultFilterId;
  Uint8List? _previewBytes;

  @override
  void initState() {
    super.initState();
    _quad = widget.initialQuad ?? Quad.defaultInset();
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
      final bytes = await ref.read(engineProvider).renderPreview(
            previewPath: widget.previewPath,
            quad: Quad.unit(),
            rotation: 0,
            filterId: filterId,
          );
      if (mounted) setState(() => _previewBytes = bytes);
    } catch (_) {}
  }

  void _openFilterSheet() => showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => FilterBottomSheet(
          previewPath: widget.previewPath,
          quad: _quad,
          rotation: _rotation,
          selectedFilterId: _filterId,
          onSelectFilter: _updatePreviewBytes,
        ),
      );

  void _retake() {
    for (final path in [widget.rawCapturePath, widget.importedPath, widget.previewPath]) {
      if (path != null) {
        try { File(path).deleteSync(); } catch (_) {}
      }
    }
    Navigator.of(context).pop(null);
  }

  Future<void> _continue() async {
    final dir = Directory(widget.importedPath).parent.path;
    final dstPath = p.join(dir, 'rendered_${DateTime.now().millisecondsSinceEpoch}.jpg');
    final rendered = await showAppProgressDialog<String>(
      context: context,
      message: 'Processing document...',
      task: () => ref.read(engineProvider).renderPage(
            srcPath: widget.importedPath,
            quad: _quad,
            rotation: _rotation,
            filterId: _filterId,
            dstPath: dstPath,
          ),
    );
    if (mounted) {
      Navigator.of(context).pop(AdjustResult(
        renderedPath: rendered,
        quad: _quad,
        rotation: _rotation,
        filterId: _filterId,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.charcoal,
      body: SafeArea(
        child: Column(
          children: [
            AdjustTopBar(onBack: () => Navigator.of(context).pop(null), pageIndicator: widget.pageIndicator),
            AdjustCropContainer(
              rotation: _rotation,
              child: CropEditor(
                previewPath: widget.previewPath,
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
    );
  }
}
