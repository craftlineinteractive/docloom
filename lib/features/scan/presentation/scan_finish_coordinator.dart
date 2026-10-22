import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import '../../../core/widgets/app_progress_dialog.dart';
import '../data/opencv_image_engine.dart';
import '../domain/scan_gateway.dart';
import '../domain/scan_session.dart';
import '../domain/scanned_page.dart';

abstract final class ScanFinishCoordinator {
  static Future<ScanSuccess?> finish({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    final session = ref.read(scanSessionProvider);
    if (session.pages.isEmpty) return null;

    final engine = ref.read(engineProvider);
    final total = session.pages.length;
    final messageNotifier = ValueNotifier<String>('Preparing page 1 of $total');

    try {
      final scannedPages = await showAppProgressDialog<List<ScannedPage>>(
        context: context,
        message: 'Preparing page 1 of $total',
        messageListenable: messageNotifier,
        task: () async {
          final result = <ScannedPage>[];
          final sessionDir = ScanSessionDirHelper.getSessionDir(session.id);
          for (var i = 0; i < total; i++) {
            messageNotifier.value = 'Preparing page ${i + 1} of $total';
            final page = session.pages[i];
            final outPath = p.join(sessionDir.path, 'rendered_${page.id}.jpg');
            await engine.renderPage(
              srcPath: page.capturePath,
              quad: page.quad,
              rotation: page.rotation,
              filterId: page.filterId,
              dstPath: outPath,
            );
            result.add(ScannedPage(
              originalPath: page.capturePath,
              editedPath: outPath,
              filterId: page.filterId,
              rotation: page.rotation,
              cropJson: jsonEncode(page.quad.toJson(type: page.cropType.name)),
            ));
          }
          return result;
        },
      );

      return ScanSuccess(scannedPages, suggestedName: session.name);
    } finally {
      messageNotifier.dispose();
    }
  }
}
