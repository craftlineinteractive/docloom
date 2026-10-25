import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_better_scanner/flutter_better_scanner.dart';
import 'package:path/path.dart' as p;
import '../../data/signature_processor.dart';
import '../../domain/camera_service.dart';
import '../../domain/scan_session.dart';
import '../signature_preview_screen.dart';

abstract final class SignatureCaptureFlow {
  static Future<List<ScanSessionPage>?> run({
    required BuildContext context,
    required CameraService camera,
    required String sessionId,
    required VoidCallback onCaptured,
    ScannerController? scannerController,
  }) async {
    final rawPath = (scannerController != null && scannerController.isReady)
        ? await scannerController.captureRaw()
        : await camera.takePicture();
    if (rawPath == null) return null;
    final sessionDir = ScanSessionDirHelper.getSessionDir(sessionId)
      ..createSync(recursive: true);
    final ts = DateTime.now().millisecondsSinceEpoch;
    final processedPath = p.join(sessionDir.path, 'sig_$ts.png');

    try {
      await SignatureProcessor.process(srcPath: rawPath, dstPath: processedPath);
    } finally {
      try { File(rawPath).deleteSync(); } catch (_) {}
    }
    onCaptured();

    if (!context.mounted) return null;
    await SignaturePreviewScreen.push(context, processedPath);
    return null;
  }
}
