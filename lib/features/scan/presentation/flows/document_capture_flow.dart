import 'package:flutter/material.dart';
import 'package:flutter_better_scanner/flutter_better_scanner.dart' hide CaptureMode, Quad;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import '../../application/capture_mode_provider.dart';
import '../../application/photo_size_providers.dart';
import '../../application/scanner_controller_provider.dart';
import '../../data/opencv_edge_detector.dart';
import '../../domain/camera_service.dart';
import '../../domain/capture_mode.dart';
import '../../domain/image_engine.dart';
import '../../domain/live_quad_mapper.dart';
import '../../domain/package_quad_adapter.dart';
import '../../domain/quad.dart';
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
    ScannerController? scannerController,
    Quad? liveQuad,
    DateTime? liveQuadTime,
  }) async {
    final mode = ref.read(captureModeProvider);
    final bookScanType = mode == CaptureMode.book ? ref.read(bookScanTypeProvider) : null;
    final photoSize = mode == CaptureMode.photo ? ref.read(photoSizesProvider).selectedSize : null;
    final edgeDet = ref.read(edgeDetectorProvider);

    if (scannerController != null && scannerController.isReady) {
      final shutterTime = DateTime.now();
      final lQuad = liveQuad ?? (scannerController.detection.value.quad != null
          ? QuadPackageAdapter.fromPackageQuad(scannerController.detection.value.quad!) : null);
      final lTime = liveQuadTime ?? (lQuad != null ? shutterTime : null);
      final page = await scannerController.capture();
      onCaptured();
      if (page == null) return null;
      final origPath = scannerController.originalPath(page) ?? '';
      final quad = (lQuad != null)
          ? await LiveQuadMapper.resolveInitialQuad(
              liveQuad: lQuad, liveQuadTime: lTime, previewAspect: 3 / 4,
              captureWidth: 3000, captureHeight: 4000, previewPath: origPath,
              detectFromFile: edgeDet.detectFromFile, shutterTime: shutterTime,
            )
          : QuadPackageAdapter.fromPackageQuad(page.cropCorners);
      if (!context.mounted) return null;
      final res = await Navigator.of(context).push<AdjustResult>(
        MaterialPageRoute(
          builder: (_) => AdjustScreen(
            previewPath: origPath, importedPath: origPath, rawCapturePath: origPath,
            initialQuad: quad, pageIndicator: pageIndicator, mode: mode,
            photoSize: photoSize, bookScanType: bookScanType,
          ),
        ),
      );
      if (res == null) {
        await scannerController.deletePage(page);
        return null;
      }
      final clamped = res.quad.clamp01();
      await scannerController.setPageCrop(page, clamped.toPackageQuad());
      await scannerController.setPageEnhancement(page, filterIdToEnhancement(res.filterId));
      final proxy = scannerController.proxyPath(page) ?? scannerController.pagePath(page) ?? origPath;
      return [
        ScanSessionPage(
          id: page.id, capturePath: origPath, previewPath: proxy, quad: clamped,
          rotation: res.rotation, filterId: res.filterId, mode: mode,
          photoSizeId: photoSize?.id, cropType: mode.cropType, packagePage: page,
        ),
      ];
    }

    final shutterInstant = DateTime.now();
    final rawPath = await camera.takePicture();
    final sessionDir = ScanSessionDirHelper.getSessionDir(sessionId)..createSync(recursive: true);
    final ts = DateTime.now().millisecondsSinceEpoch;
    final importPath = p.join(sessionDir.path, 'cap_$ts.jpg');
    final previewPath = p.join(sessionDir.path, 'prev_$ts.jpg');

    final imgSize = await engine.importCapture(srcPath: rawPath, dstPath: importPath);
    await engine.makePreview(srcPath: importPath, dstPath: previewPath);
    onCaptured();

    final rawAspect = camera.aspectRatio ?? (4 / 3);
    final previewAspect = rawAspect > 1.0 ? (1.0 / rawAspect) : rawAspect;
    final initialQuad = await LiveQuadMapper.resolveInitialQuad(
      liveQuad: liveQuad, liveQuadTime: liveQuadTime, previewAspect: previewAspect,
      captureWidth: imgSize.width.toDouble(), captureHeight: imgSize.height.toDouble(),
      previewPath: previewPath, detectFromFile: edgeDet.detectFromFile,
      shutterTime: shutterInstant,
    );

    if (!context.mounted) return null;
    final res = await Navigator.of(context).push<AdjustResult>(
      MaterialPageRoute(
        builder: (_) => AdjustScreen(
          previewPath: previewPath, importedPath: importPath, rawCapturePath: rawPath,
          initialQuad: initialQuad, pageIndicator: pageIndicator, mode: mode,
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
