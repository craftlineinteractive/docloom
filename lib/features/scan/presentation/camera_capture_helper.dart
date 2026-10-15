import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import '../domain/camera_service.dart';
import '../domain/image_engine.dart';
import 'adjust/adjust_result.dart';
import 'adjust/adjust_screen.dart';
import 'camera_debug_dialog.dart';

abstract final class CameraCaptureHelper {
  static Future<void> captureAndProcess({
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

    final ts = DateTime.now().millisecondsSinceEpoch;
    final importPath = p.join(sessionDir.path, 'cap_$ts.jpg');
    final previewPath = p.join(sessionDir.path, 'prev_$ts.jpg');

    final size = await engine.importCapture(srcPath: rawPath, dstPath: importPath);
    await engine.makePreview(srcPath: importPath, dstPath: previewPath);
    onCaptured();

    if (!context.mounted) return;
    final result = await Navigator.of(context).push<AdjustResult>(
      MaterialPageRoute(
        builder: (_) => AdjustScreen(
          previewPath: previewPath,
          importedPath: importPath,
          rawCapturePath: rawPath,
          pageIndicator: '1/1',
        ),
      ),
    );

    if (result != null && context.mounted) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => CameraDebugDialog(
          imagePath: result.renderedPath,
          size: size,
          onDismiss: () => Navigator.of(ctx).pop(),
        ),
      );
    }
  }
}
