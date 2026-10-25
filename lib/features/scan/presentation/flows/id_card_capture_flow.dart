import 'package:flutter/material.dart';
import 'package:flutter_better_scanner/flutter_better_scanner.dart' show ScannerController;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import '../../application/capture_mode_provider.dart';
import '../../domain/camera_service.dart';
import '../../domain/capture_mode.dart';
import '../../domain/crop_type.dart';
import '../../domain/image_engine.dart';
import '../../domain/quad.dart';
import '../../domain/scan_session.dart';
import '../adjust/adjust_result.dart';
import '../adjust/adjust_screen.dart';

abstract final class IdCardCaptureFlow {
  static Future<List<ScanSessionPage>?> run({
    required BuildContext context,
    required WidgetRef ref,
    required CameraService camera,
    required ImageEngine engine,
    required String sessionId,
    required VoidCallback onCaptured,
    required String pageIndicator,
    ScannerController? scannerController,
  }) async {
    final scanType = ref.read(idCardScanTypeProvider);
    final sessionDir = ScanSessionDirHelper.getSessionDir(sessionId)..createSync(recursive: true);
    final rawPath = (scannerController != null && scannerController.isReady)
        ? await scannerController.captureRaw()
        : await camera.takePicture();
    if (rawPath == null) return null;
    final ts = DateTime.now().millisecondsSinceEpoch;
    final importPath = p.join(sessionDir.path, 'id_cap_$ts.jpg');
    final previewPath = p.join(sessionDir.path, 'id_prev_$ts.jpg');

    await engine.importCapture(srcPath: rawPath, dstPath: importPath);
    await engine.makePreview(srcPath: importPath, dstPath: previewPath);
    onCaptured();

    if (!context.mounted) return null;

    if (scanType == IdCardScanType.singleSide) {
      final res = await Navigator.of(context).push<AdjustResult>(
        MaterialPageRoute(
          builder: (_) => AdjustScreen(
            previewPath: previewPath, importedPath: importPath, rawCapturePath: rawPath,
            pageIndicator: pageIndicator, mode: CaptureMode.idCard,
          ),
        ),
      );
      if (res == null) return null;
      final a4Dst = p.join(sessionDir.path, 'id_card_single_$ts.jpg');
      await engine.composeCardPage(frontPath: res.renderedPath, backPath: null, dstPath: a4Dst);
      return [
        ScanSessionPage(
          id: ts.toString(), capturePath: a4Dst, previewPath: a4Dst,
          quad: Quad.unit(), cropType: CropType.rect, mode: CaptureMode.idCard,
          rotation: 0, filterId: 'original',
        ),
      ];
    } else {
      final front = ref.read(idCardFrontProvider);
      if (front == null) {
        final res = await Navigator.of(context).push<AdjustResult>(
          MaterialPageRoute(
            builder: (_) => AdjustScreen(
              previewPath: previewPath, importedPath: importPath, rawCapturePath: rawPath,
              pageIndicator: 'Front (1/2)', mode: CaptureMode.idCard,
            ),
          ),
        );
        if (res == null) return null;
        ref.read(idCardFrontProvider.notifier).setFront(IdCardFrontResult(
          capturePath: importPath, previewPath: previewPath,
          renderedPath: res.renderedPath, quad: res.quad,
          rotation: res.rotation, filterId: res.filterId,
        ));
        return null;
      } else {
        final res = await Navigator.of(context).push<AdjustResult>(
          MaterialPageRoute(
            builder: (_) => AdjustScreen(
              previewPath: previewPath, importedPath: importPath, rawCapturePath: rawPath,
              pageIndicator: 'Back (2/2)', mode: CaptureMode.idCard,
            ),
          ),
        );
        if (res == null) {
          ref.read(idCardFrontProvider.notifier).clear();
          return null;
        }
        final a4Dst = p.join(sessionDir.path, 'id_card_both_$ts.jpg');
        await engine.composeCardPage(
          frontPath: front.renderedPath, backPath: res.renderedPath, dstPath: a4Dst,
        );
        ref.read(idCardFrontProvider.notifier).clear();
        return [
          ScanSessionPage(
            id: ts.toString(), capturePath: a4Dst, previewPath: a4Dst,
            quad: Quad.unit(), cropType: CropType.rect, mode: CaptureMode.idCard,
            rotation: 0, filterId: 'original',
          ),
        ];
      }
    }
  }
}
