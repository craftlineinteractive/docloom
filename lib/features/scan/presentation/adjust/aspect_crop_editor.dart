import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../domain/aspect_crop_helper.dart';
import '../../domain/quad.dart';
import 'crop_coordinates.dart';
import 'crop_drag_helper.dart';
import 'crop_magnifier.dart';
import 'crop_painter.dart';

class AspectCropEditor extends StatefulWidget {
  const AspectCropEditor({
    super.key,
    required this.previewPath,
    required this.quad,
    required this.targetAspectRatio,
    required this.onChanged,
    this.previewBytes,
  });

  final String previewPath;
  final Quad quad;
  final double targetAspectRatio;
  final ValueChanged<Quad> onChanged;
  final Uint8List? previewBytes;

  @override
  State<AspectCropEditor> createState() => _AspectCropEditorState();
}

class _AspectCropEditorState extends State<AspectCropEditor> {
  int? _activeCorner;
  Offset? _dragPoint;
  Offset? _lastPanPos;
  double _imageAR = 3 / 4;

  @override
  void initState() {
    super.initState();
    FileImage(File(widget.previewPath)).resolve(ImageConfiguration.empty).addListener(
      ImageStreamListener((info, _) {
        if (mounted && info.image.width > 0 && info.image.height > 0) {
          setState(() => _imageAR = info.image.width / info.image.height);
        }
      }, onError: (_, _) {}),
    );
  }

  void _onPanDown(Offset localPos, Size boxSize) {
    final pixelQuad = CropCoordinates.quadNormalizedToWidget(
      quad: widget.quad,
      boxSize: boxSize,
      imageAspectRatio: _imageAR,
    );
    final closest = CropDragHelper.findClosestCorner(pixelQuad: pixelQuad, touchPoint: localPos);
    setState(() {
      _activeCorner = closest;
      _dragPoint = localPos;
      _lastPanPos = localPos;
    });
  }

  void _onPanUpdate(DragUpdateDetails d, Size boxSize) {
    final imageRect = CropCoordinates.computeImageRect(boxSize: boxSize, imageAspectRatio: _imageAR);
    if (imageRect.width <= 0 || imageRect.height <= 0) return;

    final normAR = widget.targetAspectRatio / _imageAR;
    final currentRect = AspectCropHelper.quadToRect(widget.quad);

    if (_activeCorner != null) {
      final normPoint = CropCoordinates.widgetToNormalized(
        widgetPoint: d.localPosition,
        boxSize: boxSize,
        imageAspectRatio: _imageAR,
        clamp: true,
      );
      final newRect = AspectCropHelper.resizeCorner(
        current: currentRect,
        corner: _activeCorner!,
        newPoint: normPoint,
        normAR: normAR,
      );
      widget.onChanged(AspectCropHelper.rectToQuad(newRect));
    } else if (_lastPanPos != null) {
      final dx = (d.localPosition.dx - _lastPanPos!.dx) / imageRect.width;
      final dy = (d.localPosition.dy - _lastPanPos!.dy) / imageRect.height;
      final newRect = AspectCropHelper.moveRect(currentRect, dx, dy);
      widget.onChanged(AspectCropHelper.rectToQuad(newRect));
    }
    setState(() {
      _dragPoint = d.localPosition;
      _lastPanPos = d.localPosition;
    });
  }

  void _onPanEnd() => setState(() {
        _activeCorner = null;
        _dragPoint = null;
        _lastPanPos = null;
      });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final boxSize = Size(constraints.maxWidth, constraints.maxHeight);
      final imageRect = CropCoordinates.computeImageRect(boxSize: boxSize, imageAspectRatio: _imageAR);
      final pixelQuad = CropCoordinates.quadNormalizedToWidget(
        quad: widget.quad,
        boxSize: boxSize,
        imageAspectRatio: _imageAR,
      );

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanDown: (d) => _onPanDown(d.localPosition, boxSize),
        onPanStart: (d) => _onPanDown(d.localPosition, boxSize),
        onPanUpdate: (d) => _onPanUpdate(d, boxSize),
        onPanEnd: (_) => _onPanEnd(),
        onPanCancel: _onPanEnd,
        child: Stack(fit: StackFit.expand, children: [
          if (imageRect.width > 0 && imageRect.height > 0)
            Positioned.fromRect(
              rect: imageRect,
              child: widget.previewBytes != null
                  ? Image.memory(widget.previewBytes!, fit: BoxFit.fill)
                  : Image.file(File(widget.previewPath), fit: BoxFit.fill),
            ),
          CustomPaint(
            painter: CropPainter(quad: pixelQuad, imageRect: imageRect, activeCorner: _activeCorner),
          ),
          if (_dragPoint != null && _activeCorner != null)
            CropMagnifier(focalPoint: _dragPoint!, boxSize: boxSize),
        ]),
      );
    });
  }
}
