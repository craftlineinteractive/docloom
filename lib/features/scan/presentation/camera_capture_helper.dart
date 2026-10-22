import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/capture_mode_provider.dart';
import '../domain/camera_service.dart';
import '../domain/capture_mode.dart';
import '../domain/image_engine.dart';
import '../domain/scan_session.dart';
import 'flows/document_capture_flow.dart';
import 'flows/id_card_capture_flow.dart';
import 'flows/signature_capture_flow.dart';

abstract final class CameraCaptureHelper {
  static Future<List<ScanSessionPage>?> captureAndProcess({
    required BuildContext context,
    required WidgetRef ref,
    required CameraService camera,
    required ImageEngine engine,
    required String sessionId,
    required VoidCallback onCaptured,
    String pageIndicator = '1/1',
  }) async {
    final mode = ref.read(captureModeProvider);

    if (mode == CaptureMode.signature) {
      return SignatureCaptureFlow.run(
        context: context,
        camera: camera,
        sessionId: sessionId,
        onCaptured: onCaptured,
      );
    }

    if (mode == CaptureMode.idCard) {
      return IdCardCaptureFlow.run(
        context: context,
        ref: ref,
        camera: camera,
        engine: engine,
        sessionId: sessionId,
        onCaptured: onCaptured,
        pageIndicator: pageIndicator,
      );
    }

    return DocumentCaptureFlow.run(
      context: context,
      ref: ref,
      camera: camera,
      engine: engine,
      sessionId: sessionId,
      onCaptured: onCaptured,
      pageIndicator: pageIndicator,
    );
  }
}
