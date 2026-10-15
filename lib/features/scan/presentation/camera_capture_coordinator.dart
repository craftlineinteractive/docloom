import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_config.dart';
import '../../../core/widgets/app_toast.dart';
import '../data/opencv_image_engine.dart';
import '../domain/camera_service.dart';
import '../domain/scan_session.dart';
import 'camera_capture_helper.dart';

abstract final class CameraCaptureCoordinator {
  static Future<void> performCapture({
    required BuildContext context,
    required WidgetRef ref,
    required CameraService camera,
    required int? retakePageIndex,
    required VoidCallback onStart,
    required VoidCallback onEnd,
  }) async {
    onStart();
    final session = ref.read(scanSessionProvider);
    final indicator = retakePageIndex != null
        ? '${retakePageIndex + 1}/${session.pages.length}'
        : '${session.pages.length + 1}';
    try {
      final page = await CameraCaptureHelper.captureAndProcess(
        context: context,
        camera: camera,
        engine: ref.read(engineProvider),
        sessionId: session.id,
        pageIndicator: indicator,
        onCaptured: onEnd,
      );
      if (page != null && context.mounted) {
        if (retakePageIndex != null) {
          Navigator.of(context).pop(page);
          return;
        }
        if (!ref.read(scanSessionProvider.notifier).addPage(page)) {
          showAppToastGlobal('Page limit reached (${AppConfig.scanPageLimit} pages)');
        }
      }
    } catch (_) {
      showAppToastGlobal('Capture failed. Please try again.');
    } finally {
      onEnd();
    }
  }
}
