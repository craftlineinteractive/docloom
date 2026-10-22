import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../application/capture_mode_provider.dart';
import '../domain/camera_service.dart';
import '../domain/capture_mode.dart';
import 'camera_bottom_bar.dart';
import 'camera_mode_row.dart';
import 'camera_top_bar.dart';
import 'camera_viewfinder.dart';
import 'widgets/camera_settings_grid_panel.dart';
import 'widgets/id_card_step_banner.dart';
import 'widgets/qr_cutout_overlay.dart';
import 'widgets/signature_reticle_overlay.dart';

class CameraBody extends ConsumerWidget {
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
    this.isSettingsOpen = false,
    this.onSettingsTap,
    this.onCloseSettings,
    this.onHomeScreenTap,
  });

  final Widget? leftSlot, rightSlot;
  final CameraService camera;
  final bool isGridVisible;
  final Offset? focusPos;
  final bool isInitializing, isCapturing, isSettingsOpen;
  final VoidCallback onBack, onToggleFlash, onToggleGrid, onFlipCamera, onDismissFocus, onCapture;
  final void Function(TapDownDetails details, Size size) onTapPreview;
  final VoidCallback? onSettingsTap, onCloseSettings, onHomeScreenTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(captureModeProvider);
    final idCardFront = ref.watch(idCardFrontProvider);

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
              onSettingsTap: onSettingsTap,
              isSettingsOpen: isSettingsOpen,
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
              isOverlayHidden: isSettingsOpen,
              modeOverlay: Stack(
                fit: StackFit.expand,
                children: [
                  if (mode == CaptureMode.signature) const SignatureReticleOverlay(),
                  if (mode == CaptureMode.qr) const QrCutoutOverlay(),
                  if (mode == CaptureMode.idCard && idCardFront != null)
                    Positioned(
                      top: 0, left: 0, right: 0,
                      child: IdCardStepBanner(
                        step: 2,
                        onCancel: () => ref.read(idCardFrontProvider.notifier).clear(),
                      ),
                    ),
                ],
              ),
              settingsPanel: isSettingsOpen
                  ? CameraSettingsGridPanel(
                      onClose: onCloseSettings ?? () {},
                      onHomeScreenTap: onHomeScreenTap ?? () {},
                    )
                  : null,
            ),
            const CameraModeRow(),
            CameraBottomBar(
              onCapture: onCapture,
              isEnabled: !isInitializing && !isCapturing && !isSettingsOpen,
              isCapturing: isCapturing,
              isQrMode: mode == CaptureMode.qr,
              leftSlot: leftSlot,
              rightSlot: rightSlot,
            ),
          ],
        ),
      ),
    );
  }
}
