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
    this.settingsPanel,
    this.isOverlayHidden = false,
  });

  final CameraService camera;
  final bool isGridVisible;
  final Offset? focusPos;
  final void Function(TapDownDetails details, Size size) onTapPreview;
  final VoidCallback onDismissFocus;
  final Widget? settingsPanel;
  final bool isOverlayHidden;

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
            child: Stack(
              fit: StackFit.expand,
              children: [
                GestureDetector(
                  onTapDown: isOverlayHidden ? null : (details) => onTapPreview(details, size),
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: previewWidth,
                      height: previewHeight,
                      child: camera.previewWidget(),
                    ),
                  ),
                ),
                if (isGridVisible && !isOverlayHidden) const CameraGrid(),
                if (focusPos != null && !isOverlayHidden)
                  FocusRing(position: focusPos!, onDismiss: onDismissFocus),
                if (settingsPanel != null) Positioned.fill(child: settingsPanel!),
              ],
            ),
          );
        },
      ),
    );
  }
}
