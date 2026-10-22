import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../application/capture_mode_provider.dart';
import '../../domain/capture_mode.dart';
import '../../domain/photo_size.dart';
import '../../domain/quad.dart';
import 'aspect_crop_editor.dart';
import 'book_split_overlay.dart';
import 'crop_editor.dart';

class AdjustEditorContent extends StatelessWidget {
  const AdjustEditorContent({
    super.key,
    required this.mode,
    required this.importedPath,
    required this.previewBytes,
    required this.quad,
    required this.onQuadChanged,
    required this.splitRatio,
    required this.onSplitChanged,
    this.photoSize,
    this.bookScanType,
  });

  final CaptureMode mode;
  final String importedPath;
  final Uint8List? previewBytes;
  final Quad quad;
  final ValueChanged<Quad> onQuadChanged;
  final double splitRatio;
  final ValueChanged<double> onSplitChanged;
  final PhotoSize? photoSize;
  final BookScanType? bookScanType;

  @override
  Widget build(BuildContext context) {
    if (mode == CaptureMode.photo && photoSize != null) {
      final p = photoSize!.pixelSize;
      return AspectCropEditor(
        previewPath: importedPath,
        previewBytes: previewBytes,
        quad: quad,
        targetAspectRatio: p.width / p.height,
        onChanged: onQuadChanged,
      );
    }
    final isBookSplit = mode == CaptureMode.book && bookScanType == BookScanType.twoPagesSplit;
    return Stack(children: [
      CropEditor(
        previewPath: importedPath,
        previewBytes: previewBytes,
        quad: quad,
        onChanged: onQuadChanged,
      ),
      if (isBookSplit)
        BookSplitOverlay(
          splitRatio: splitRatio,
          imageAspectRatio: 3 / 4,
          onChanged: onSplitChanged,
        ),
    ]);
  }
}
