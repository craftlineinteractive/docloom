import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/camera_service.dart';
import 'camera_bottom_bar.dart';
import 'camera_mode_row.dart';
import 'camera_top_bar.dart';
import 'camera_viewfinder.dart';

class CameraBody extends StatelessWidget {
  const CameraBody({
    super.key,
    required this.camera,
    required this.isGridVisible,
    required this.focusPos,
    required this.isInitializing,
    required this.isCapturing,
    required this.onBack,
    required this.onToggleFlash,
    required this.onToggleGrid,
    required this.onFlipCamera,
    required this.onTapPreview,
    required this.onDismissFocus,
    required this.onCapture,
    this.leftSlot,
    this.rightSlot,
  });

  final Widget? leftSlot;
  final Widget? rightSlot;

  final CameraService camera;
  final bool isGridVisible;
  final Offset? focusPos;
  final bool isInitializing;
  final bool isCapturing;
  final VoidCallback onBack;
  final VoidCallback onToggleFlash;
  final VoidCallback onToggleGrid;
  final VoidCallback onFlipCamera;
  final void Function(TapDownDetails details, Size size) onTapPreview;
  final VoidCallback onDismissFocus;
  final VoidCallback onCapture;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cameraBlack,
      body: SafeArea(
        child: Column(
          children: [
            CameraTopBar(
              onBack: onBack,
              onFlashTap: onToggleFlash,
              onGridTap: onToggleGrid,
              onFlipTap: onFlipCamera,
              currentFlash: camera.currentFlash,
              isGridVisible: isGridVisible,
              showFlip: camera.availableLenses.length > 1,
            ),
            CameraViewfinder(
              camera: camera,
              isGridVisible: isGridVisible,
              focusPos: focusPos,
              onTapPreview: onTapPreview,
              onDismissFocus: onDismissFocus,
            ),
            const CameraModeRow(),
            CameraBottomBar(
              onCapture: onCapture,
              isEnabled: !isInitializing && !isCapturing,
              isCapturing: isCapturing,
              leftSlot: leftSlot,
              rightSlot: rightSlot,
            ),
          ],
        ),
      ),
    );
  }
}
