import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import '../../../ocr/presentation/ocr_result_screen.dart';
import '../../domain/camera_service.dart';
import '../../domain/capture_mode.dart';
import '../../domain/image_engine.dart';
import '../../domain/scan_session.dart';
import '../adjust/adjust_result.dart';
import '../adjust/adjust_screen.dart';

abstract final class OcrCaptureFlow {
  static Future<List<ScanSessionPage>?> run({
    required BuildContext context,
    required WidgetRef ref,
    required CameraService camera,
    required ImageEngine engine,
    required String sessionId,
    required VoidCallback onCaptured,
    required String pageIndicator,
  }) async {
    final rawPath = await camera.takePicture();
    final sessionDir = ScanSessionDirHelper.getSessionDir(sessionId)..createSync(recursive: true);
    final ts = DateTime.now().millisecondsSinceEpoch;
    final importPath = p.join(sessionDir.path, 'cap_$ts.jpg');
    final previewPath = p.join(sessionDir.path, 'prev_$ts.jpg');

    await engine.importCapture(srcPath: rawPath, dstPath: importPath);
    await engine.makePreview(srcPath: importPath, dstPath: previewPath);
    onCaptured();

    if (!context.mounted) return null;
    final res = await Navigator.of(context).push<AdjustResult>(
      MaterialPageRoute(
        builder: (_) => AdjustScreen(
          previewPath: previewPath,
          importedPath: importPath,
          rawCapturePath: rawPath,
          pageIndicator: pageIndicator,
          mode: CaptureMode.ocr,
        ),
      ),
    );
    if (res == null || !context.mounted) return null;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OcrResultScreen(imagePath: res.renderedPath),
      ),
    );

    return [
      ScanSessionPage(
        id: ts.toString(),
        capturePath: res.renderedPath,
        previewPath: previewPath,
        quad: res.quad,
        rotation: res.rotation,
        filterId: res.filterId,
        mode: CaptureMode.ocr,
        cropType: CaptureMode.ocr.cropType,
      ),
    ];
  }
}
