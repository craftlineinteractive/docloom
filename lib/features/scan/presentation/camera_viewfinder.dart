import 'package:flutter/material.dart';
import '../../../core/theme/app_sizes.dart';
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
      child: Center(
        child: AspectRatio(
          aspectRatio: AppSizes.cameraRatio,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, constraints.maxHeight);
              return GestureDetector(
                onTapDown: (details) => onTapPreview(details, size),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    camera.previewWidget(),
                    if (isGridVisible) const CameraGrid(),
                    if (focusPos != null)
                      FocusRing(
                        position: focusPos!,
                        onDismiss: onDismissFocus,
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
