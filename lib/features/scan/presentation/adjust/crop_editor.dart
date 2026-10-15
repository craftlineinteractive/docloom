import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/quad.dart';
import 'crop_coordinates.dart';
import 'crop_drag_helper.dart';
import 'crop_magnifier.dart';
import 'crop_painter.dart';

class CropEditor extends StatefulWidget {
  const CropEditor({
    super.key,
    required this.previewPath,
    required this.quad,
    required this.onChanged,
    this.previewBytes,
    this.aspectRatio,
  });

  final String previewPath;
  final Quad quad;
  final ValueChanged<Quad> onChanged;
  final Uint8List? previewBytes;
  final double? aspectRatio;

  @override
  State<CropEditor> createState() => _CropEditorState();
}

class _CropEditorState extends State<CropEditor> {
  int? _activeCorner;
  Offset? _dragPoint;
  double _aspectRatio = 3 / 4;

  @override
  void initState() {
    super.initState();
    if (widget.aspectRatio != null) {
      _aspectRatio = widget.aspectRatio!;
    } else {
      FileImage(File(widget.previewPath)).resolve(ImageConfiguration.empty).addListener(
        ImageStreamListener((info, _) {
          if (mounted && info.image.width > 0 && info.image.height > 0) {
            setState(() => _aspectRatio = info.image.width / info.image.height);
          }
        }, onError: (_, _) {}),
      );
    }
  }

  void _onPanDown(Offset localPos, Size boxSize) {
    final pixelQuad = CropCoordinates.quadNormalizedToWidget(
      quad: widget.quad,
      boxSize: boxSize,
      imageAspectRatio: _aspectRatio,
    );
    final closest = CropDragHelper.findClosestCorner(pixelQuad: pixelQuad, touchPoint: localPos);
    if (closest != null) {
      setState(() {
        _activeCorner = closest;
        _dragPoint = localPos;
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails d, Size boxSize) {
    if (_activeCorner == null) return;
    final normPoint = CropCoordinates.widgetToNormalized(
      widgetPoint: d.localPosition,
      boxSize: boxSize,
      imageAspectRatio: _aspectRatio,
      clamp: true,
    );
    final candidate = CropDragHelper.updateCorner(
      current: widget.quad,
      corner: _activeCorner!,
      newPoint: normPoint,
    );
    if (candidate.isValid) widget.onChanged(candidate);
    setState(() => _dragPoint = d.localPosition);
  }

  void _onPanEnd() => setState(() {
        _activeCorner = null;
        _dragPoint = null;
      });

  Widget _buildImage() {
    final bytes = widget.previewBytes;
    if (bytes != null) {
      return Image.memory(
        bytes,
        fit: BoxFit.fill,
        errorBuilder: (_, _, _) => const ColoredBox(color: AppColors.cropDeskBg),
      );
    }
    return Image.file(
      File(widget.previewPath),
      fit: BoxFit.fill,
      errorBuilder: (_, _, _) => const ColoredBox(color: AppColors.cropDeskBg),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxSize = Size(constraints.maxWidth, constraints.maxHeight);
        final imageRect = CropCoordinates.computeImageRect(boxSize: boxSize, imageAspectRatio: _aspectRatio);
        final pixelQuad = CropCoordinates.quadNormalizedToWidget(
          quad: widget.quad,
          boxSize: boxSize,
          imageAspectRatio: _aspectRatio,
        );

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanDown: (d) => _onPanDown(d.localPosition, boxSize),
          onPanStart: (d) => _onPanDown(d.localPosition, boxSize),
          onPanUpdate: (d) => _onPanUpdate(d, boxSize),
          onPanEnd: (_) => _onPanEnd(),
          onPanCancel: _onPanEnd,
          child: Stack(
            clipBehavior: Clip.none,
            fit: StackFit.expand,
            children: [
              if (imageRect.width > 0 && imageRect.height > 0)
                Positioned.fromRect(rect: imageRect, child: _buildImage()),
              CustomPaint(
                painter: CropPainter(quad: pixelQuad, imageRect: imageRect, activeCorner: _activeCorner),
              ),
              if (_dragPoint != null && _activeCorner != null)
                CropMagnifier(focalPoint: _dragPoint!, boxSize: boxSize),
            ],
          ),
        );
      },
    );
  }
}
