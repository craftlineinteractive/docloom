import 'dart:async';
import 'dart:typed_data';
import '../domain/image_engine.dart';
import '../domain/quad.dart';

class FakeImageEngine implements ImageEngine {
  FakeImageEngine({
    this.importSize = const ImageSize(width: 2000, height: 1500),
  });

  ImageSize importSize;
  Completer<ImageSize>? completer;

  int importCaptureCount = 0;
  int makePreviewCount = 0;
  int renderPageCount = 0;
  int renderPreviewCount = 0;
  int composeCardCount = 0;

  String? lastImportSrc;
  String? lastImportDst;
  String? lastPreviewSrc;
  String? lastPreviewDst;

  String? lastRenderSrc;
  Quad? lastRenderQuad;
  int? lastRenderRotation;
  String? lastRenderFilterId;
  String? lastRenderDst;
  int? lastRenderWidth;
  int? lastRenderHeight;

  String? lastPreviewRenderPath;
  Quad? lastPreviewRenderQuad;
  int? lastPreviewRenderRotation;
  String? lastPreviewRenderFilterId;
  int? lastPreviewRenderMaxSide;

  String? lastComposeFront;
  String? lastComposeBack;
  String? lastComposeDst;

  Uint8List previewBytes = Uint8List.fromList(const [
    137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82,
    0, 0, 0, 1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137,
    0, 0, 0, 10, 73, 68, 65, 84, 120, 156, 99, 0, 1, 0, 0, 5,
    0, 1, 13, 10, 45, 180, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130
  ]);

  @override
  Future<ImageSize> importCapture({required String srcPath, required String dstPath}) async {
    importCaptureCount++;
    lastImportSrc = srcPath;
    lastImportDst = dstPath;
    if (completer != null) return completer!.future;
    return importSize;
  }

  @override
  Future<String> makePreview({required String srcPath, required String dstPath}) async {
    makePreviewCount++;
    lastPreviewSrc = srcPath;
    lastPreviewDst = dstPath;
    return dstPath;
  }

  @override
  Future<String> renderPage({
    required String srcPath,
    required Quad quad,
    required int rotation,
    required String filterId,
    required String dstPath,
    int? targetWidth,
    int? targetHeight,
  }) async {
    renderPageCount++;
    lastRenderSrc = srcPath;
    lastRenderQuad = quad;
    lastRenderRotation = rotation;
    lastRenderFilterId = filterId;
    lastRenderDst = dstPath;
    lastRenderWidth = targetWidth;
    lastRenderHeight = targetHeight;
    return dstPath;
  }

  @override
  Future<Uint8List> renderPreview({
    required String previewPath,
    required Quad quad,
    required int rotation,
    required String filterId,
    int? maxSide,
  }) async {
    renderPreviewCount++;
    lastPreviewRenderPath = previewPath;
    lastPreviewRenderQuad = quad;
    lastPreviewRenderRotation = rotation;
    lastPreviewRenderFilterId = filterId;
    lastPreviewRenderMaxSide = maxSide;
    return previewBytes;
  }

  @override
  Future<String> composeCardPage({
    required String frontPath,
    String? backPath,
    required String dstPath,
  }) async {
    composeCardCount++;
    lastComposeFront = frontPath;
    lastComposeBack = backPath;
    lastComposeDst = dstPath;
    return dstPath;
  }
}
