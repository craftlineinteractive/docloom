import 'package:flutter/material.dart';
import '../domain/camera_service.dart';
import 'camera_grid.dart';
import 'focus_ring.dart';

class CameraViewfinder extends StatelessWidget {
  const CameraViewfinder({
    super.key,
    required this.camera,
    required this.isGridVisible,
    required this.focusPos,
    required this.onTapPreview,
    required this.onDismissFocus,
  });

  final CameraService camera;
  final bool isGridVisible;
  final Offset? focusPos;
  final void Function(TapDownDetails details, Size size) onTapPreview;
  final VoidCallback onDismissFocus;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          final rawAspect = camera.aspectRatio ?? (4 / 3);
          final previewAspect = rawAspect > 1.0 ? (1.0 / rawAspect) : rawAspect;
          final previewWidth = size.width;
          final previewHeight = previewWidth / previewAspect;

          return ClipRect(
            child: GestureDetector(
              onTapDown: (details) => onTapPreview(details, size),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: previewWidth,
                      height: previewHeight,
                      child: camera.previewWidget(),
                    ),
                  ),
                  if (isGridVisible) const CameraGrid(),
                  if (focusPos != null)
                    FocusRing(
                      position: focusPos!,
                      onDismiss: onDismissFocus,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
