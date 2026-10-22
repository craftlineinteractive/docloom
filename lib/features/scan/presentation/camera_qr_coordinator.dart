import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/capture_mode_provider.dart';
import '../application/qr_scan_state.dart';
import '../application/qr_scanner_providers.dart';
import '../domain/camera_service.dart';
import '../domain/capture_mode.dart';
import 'widgets/qr_result_bottom_sheet.dart';

abstract final class CameraQrCoordinator {
  static void setup({
    required BuildContext context,
    required WidgetRef ref,
    required CameraService camera,
  }) {
    ref.listen<CaptureMode>(captureModeProvider, (prev, next) {
      if (next == CaptureMode.qr) {
        _startStreaming(camera, ref);
      } else if (prev == CaptureMode.qr) {
        camera.stopImageStream();
      }
    });

    ref.listen<QrScanState>(qrScanControllerProvider, (prev, next) {
      if (next.isSheetOpen && next.currentResult != null && prev?.isSheetOpen != true) {
        QrResultBottomSheet.show(
          context,
          next.currentResult!,
          () => ref.read(qrScanControllerProvider.notifier).dismissResult(),
        ).then((_) {
          if (context.mounted) {
            ref.read(qrScanControllerProvider.notifier).dismissResult();
          }
        });
      }
    });
  }

  static void startIfActive({
    required WidgetRef ref,
    required CameraService camera,
  }) {
    if (ref.read(captureModeProvider) == CaptureMode.qr) {
      _startStreaming(camera, ref);
    }
  }

  static void _startStreaming(CameraService camera, WidgetRef ref) {
    camera.startImageStream((bytes, width, height) {
      ref.read(qrScanControllerProvider.notifier).processFrame(bytes, width, height);
    });
  }
}
