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

  String? lastImportSrc;
  String? lastImportDst;
  String? lastPreviewSrc;
  String? lastPreviewDst;

  String? lastRenderSrc;
  Quad? lastRenderQuad;
  int? lastRenderRotation;
  String? lastRenderFilterId;
  String? lastRenderDst;

  String? lastPreviewRenderPath;
  Quad? lastPreviewRenderQuad;
  int? lastPreviewRenderRotation;
  String? lastPreviewRenderFilterId;
  int? lastPreviewRenderMaxSide;
  Uint8List previewBytes = Uint8List.fromList([1, 2, 3]);

  @override
  Future<ImageSize> importCapture({
    required String srcPath,
    required String dstPath,
  }) async {
    importCaptureCount++;
    lastImportSrc = srcPath;
    lastImportDst = dstPath;
    if (completer != null) return completer!.future;
    return importSize;
  }

  @override
  Future<String> makePreview({
    required String srcPath,
    required String dstPath,
  }) async {
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
  }) async {
    renderPageCount++;
    lastRenderSrc = srcPath;
    lastRenderQuad = quad;
    lastRenderRotation = rotation;
    lastRenderFilterId = filterId;
    lastRenderDst = dstPath;
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
}
