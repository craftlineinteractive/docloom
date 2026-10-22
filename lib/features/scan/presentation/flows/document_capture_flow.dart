import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import '../../application/capture_mode_provider.dart';
import '../../application/photo_size_providers.dart';
import '../../domain/camera_service.dart';
import '../../domain/capture_mode.dart';
import '../../domain/image_engine.dart';
import '../../domain/scan_session.dart';
import '../adjust/adjust_result.dart';
import '../adjust/adjust_screen.dart';

abstract final class DocumentCaptureFlow {
  static Future<List<ScanSessionPage>?> run({
    required BuildContext context,
    required WidgetRef ref,
    required CameraService camera,
    required ImageEngine engine,
    required String sessionId,
    required VoidCallback onCaptured,
    required String pageIndicator,
  }) async {
    final mode = ref.read(captureModeProvider);
    final bookScanType = mode == CaptureMode.book ? ref.read(bookScanTypeProvider) : null;
    final photoSize = mode == CaptureMode.photo
        ? ref.read(photoSizesProvider).selectedSize
        : null;

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
          previewPath: previewPath, importedPath: importPath, rawCapturePath: rawPath,
          pageIndicator: pageIndicator, mode: mode,
          photoSize: photoSize, bookScanType: bookScanType,
        ),
      ),
    );
    if (res == null) return null;

    final cropType = mode.cropType;
    final photoSizeId = photoSize?.id;

    if (res.secondaryRenderedPath != null && res.secondaryQuad != null) {
      return [
        ScanSessionPage(
          id: '${ts}_1', capturePath: res.renderedPath, previewPath: previewPath,
          quad: res.quad, rotation: res.rotation, filterId: res.filterId,
          mode: mode, cropType: cropType,
        ),
        ScanSessionPage(
          id: '${ts}_2', capturePath: res.secondaryRenderedPath!, previewPath: previewPath,
          quad: res.secondaryQuad!, rotation: res.rotation, filterId: res.filterId,
          mode: mode, cropType: cropType,
        ),
      ];
    }

    return [
      ScanSessionPage(
        id: ts.toString(), capturePath: res.renderedPath, previewPath: previewPath,
        quad: res.quad, rotation: res.rotation, filterId: res.filterId,
        mode: mode, photoSizeId: photoSizeId, cropType: cropType,
      ),
    ];
  }
}
