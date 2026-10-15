import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import '../domain/camera_service.dart';
import '../domain/image_engine.dart';
import '../domain/scan_session.dart';
import 'adjust/adjust_result.dart';
import 'adjust/adjust_screen.dart';

abstract final class CameraCaptureHelper {
  static Future<ScanSessionPage?> captureAndProcess({
    required BuildContext context,
    required CameraService camera,
    required ImageEngine engine,
    required String sessionId,
    required VoidCallback onCaptured,
    String pageIndicator = '1/1',
  }) async {
    final rawPath = await camera.takePicture();
    final sessionDir = ScanSessionDirHelper.getSessionDir(sessionId)
      ..createSync(recursive: true);

    final ts = DateTime.now().millisecondsSinceEpoch;
    final importPath = p.join(sessionDir.path, 'cap_$ts.jpg');
    final previewPath = p.join(sessionDir.path, 'prev_$ts.jpg');

    await engine.importCapture(srcPath: rawPath, dstPath: importPath);
    await engine.makePreview(srcPath: importPath, dstPath: previewPath);
    onCaptured();

    if (!context.mounted) return null;
    final result = await Navigator.of(context).push<AdjustResult>(
      MaterialPageRoute(
        builder: (_) => AdjustScreen(
          previewPath: previewPath,
          importedPath: importPath,
          rawCapturePath: rawPath,
          pageIndicator: pageIndicator,
        ),
      ),
    );

    if (result != null) {
      return ScanSessionPage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        capturePath: importPath,
        previewPath: previewPath,
        quad: result.quad,
        rotation: result.rotation,
        filterId: result.filterId,
      );
    }
    return null;
  }
}
