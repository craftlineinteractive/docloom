import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import '../domain/camera_service.dart';
import '../domain/image_engine.dart';
import 'camera_debug_dialog.dart';

abstract final class CameraCaptureHelper {
  static Future<void> captureAndShowDebug({
    required BuildContext context,
    required CameraService camera,
    required ImageEngine engine,
    required String sessionId,
    required VoidCallback onCaptured,
  }) async {
    final rawPath = await camera.takePicture();
    final sessionDir = Directory(
      p.join(Directory.systemTemp.path, 'docloom_cache', 'scan_session', sessionId),
    )..createSync(recursive: true);
    final dst = p.join(
      sessionDir.path,
      'cap_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    final size = await engine.importCapture(srcPath: rawPath, dstPath: dst);
    onCaptured();
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => CameraDebugDialog(
        imagePath: dst,
        size: size,
        onDismiss: () => Navigator.of(ctx).pop(),
      ),
    );
  }
}
