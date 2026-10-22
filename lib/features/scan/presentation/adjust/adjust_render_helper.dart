import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import '../../../../core/widgets/app_progress_dialog.dart';
import '../../application/capture_mode_provider.dart';
import '../../data/opencv_image_engine.dart';
import '../../domain/book_split_helper.dart';
import '../../domain/capture_mode.dart';
import '../../domain/photo_size.dart';
import '../../domain/quad.dart';
import 'adjust_result.dart';

class AdjustRenderHelper {
  const AdjustRenderHelper._();

  static Future<AdjustResult?> processContinue({
    required BuildContext context,
    required WidgetRef ref,
    required String importedPath,
    required Quad quad,
    required int rotation,
    required String filterId,
    CaptureMode mode = CaptureMode.document,
    PhotoSize? photoSize,
    BookScanType? bookScanType,
    double splitRatio = 0.5,
  }) async {
    final dir = Directory(importedPath).parent.path;
    final engine = ref.read(engineProvider);

    if (mode == CaptureMode.photo && photoSize != null) {
      final pixels = photoSize.pixelSize;
      final dst = p.join(dir, 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg');
      final res = await showAppProgressDialog<String>(
        context: context,
        message: 'Rendering ID photo...',
        task: () => engine.renderPage(
          srcPath: importedPath,
          quad: quad,
          rotation: rotation,
          filterId: filterId,
          dstPath: dst,
          targetWidth: pixels.width,
          targetHeight: pixels.height,
        ),
      );
      return AdjustResult(renderedPath: res, quad: quad, rotation: rotation, filterId: filterId);
    }

    if (mode == CaptureMode.book && bookScanType == BookScanType.twoPagesSplit) {
      final split = BookSplitHelper.splitQuad(quad, splitRatio);
      final ts = DateTime.now().millisecondsSinceEpoch;
      final dst1 = p.join(dir, 'book_page_1_$ts.jpg');
      final dst2 = p.join(dir, 'book_page_2_$ts.jpg');

      final results = await showAppProgressDialog<List<String>>(
        context: context,
        message: 'Splitting book pages...',
        task: () async {
          final p1 = await engine.renderPage(
            srcPath: importedPath,
            quad: split.left,
            rotation: rotation,
            filterId: filterId,
            dstPath: dst1,
          );
          final p2 = await engine.renderPage(
            srcPath: importedPath,
            quad: split.right,
            rotation: rotation,
            filterId: filterId,
            dstPath: dst2,
          );
          return [p1, p2];
        },
      );
      return AdjustResult(
        renderedPath: results[0],
        quad: split.left,
        rotation: rotation,
        filterId: filterId,
        secondaryRenderedPath: results[1],
        secondaryQuad: split.right,
      );
    }

    final dst = p.join(dir, 'rendered_${DateTime.now().millisecondsSinceEpoch}.jpg');
    final res = await showAppProgressDialog<String>(
      context: context,
      message: 'Processing document...',
      task: () => engine.renderPage(
        srcPath: importedPath,
        quad: quad,
        rotation: rotation,
        filterId: filterId,
        dstPath: dst,
      ),
    );
    return AdjustResult(renderedPath: res, quad: quad, rotation: rotation, filterId: filterId);
  }
}
