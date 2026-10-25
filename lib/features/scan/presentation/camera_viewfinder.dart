import 'package:flutter/material.dart';
import 'package:flutter_better_scanner/flutter_better_scanner.dart';
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
    this.scannerController,
    this.settingsPanel,
    this.modeOverlay,
    this.isOverlayHidden = false,
  });

  final CameraService camera;
  final ScannerController? scannerController;
  final bool isGridVisible;
  final Offset? focusPos;
  final void Function(TapDownDetails details, Size size) onTapPreview;
  final VoidCallback onDismissFocus;
  final Widget? settingsPanel;
  final Widget? modeOverlay;
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
          final sc = scannerController;

          return ClipRect(
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (sc != null && sc.isReady)
                  ScannerPreview(
                    controller: sc,
                    showOutline: true,
                    showGuide: false,
                    showGrid: false,
                    enableTapToFocus: true,
                  )
                else
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
                if (modeOverlay != null && !isOverlayHidden) modeOverlay!,
                if (settingsPanel != null) Positioned.fill(child: settingsPanel!),
              ],
            ),
          );
        },
      ),
    );
  }
}
