import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter_better_scanner/scanner_core.dart' as s_core;
import 'package:opencv_dart/opencv_dart.dart' as cv;

class SpikeResult {
  const SpikeResult({
    required this.fileName,
    required this.iou,
    required this.ms,
    required this.detected,
  });
  final String fileName;
  final double iou;
  final double ms;
  final bool detected;
}

abstract final class ScannerSpikeRunner {
  static const fixtureNames = [
    '01_baseline', '02_baseline', '03_baseline', '04_tilted_page',
    '05_tilted_page', '06_rotated_page', '07_rotated_page', '08_shadow_page',
    '09_shadow_page', '10_dim_light', '11_dim_light', '12_patterned_desk',
    '13_patterned_desk', '14_white_on_white', '15_book_cover', '16_open_book',
    '17_reciept_bill', '18_blank_card', '19_croped_page_edge',
  ];

  static double computeIoU(List<ui.Offset> q, List<ui.Offset> g) {
    final v1 = cv.VecPoint.fromList(
      q.map((p) => cv.Point((p.dx * 1000).round(), (p.dy * 1000).round())).toList(),
    );
    final v2 = cv.VecPoint.fromList(
      g.map((p) => cv.Point((p.dx * 1000).round(), (p.dy * 1000).round())).toList(),
    );
    try {
      final (interArea, p12) = cv.intersectConvexConvex(v1, v2);
      p12.dispose();
      final a1 = cv.contourArea(v1), a2 = cv.contourArea(v2);
      final unionArea = a1 + a2 - interArea;
      return unionArea > 0 ? (interArea / unionArea).clamp(0.0, 1.0) : 0.0;
    } finally {
      v1.dispose();
      v2.dispose();
    }
  }

  static s_core.RgbaImage matToRgba(cv.Mat bgr) {
    final rgbaMat = cv.cvtColor(bgr, cv.COLOR_BGR2RGBA);
    final bytes = Uint8List.fromList(rgbaMat.data);
    final rgba = s_core.RgbaImage(bytes, rgbaMat.cols, rgbaMat.rows);
    rgbaMat.dispose();
    return rgba;
  }

  static Future<SpikeResult> evaluateFixture({
    required String name,
    required Uint8List jpgBytes,
    required String jsonStr,
  }) async {
    final gtJson = jsonDecode(jsonStr) as Map<String, dynamic>;
    final gtCorners = (gtJson['corners'] as List)
        .map((p) => ui.Offset((p[0] as num).toDouble(), (p[1] as num).toDouble()))
        .toList();

    final bgr = cv.imdecode(jpgBytes, cv.IMREAD_COLOR);
    final rgba = matToRgba(bgr);
    bgr.dispose();

    final sw = Stopwatch()..start();
    final quad = s_core.ScannerCv.detectDocument(rgba);
    sw.stop();
    final ms = sw.elapsedMicroseconds / 1000.0;

    if (quad == null) {
      return SpikeResult(fileName: '$name.jpg', iou: 0.0, ms: ms, detected: false);
    }
    final qCorners = [quad.tl, quad.tr, quad.br, quad.bl];
    final iou = computeIoU(qCorners, gtCorners);
    return SpikeResult(fileName: '$name.jpg', iou: iou, ms: ms, detected: true);
  }

  static Future<void> renderFiltersForFixture({
    required String name,
    required Uint8List jpgBytes,
    required Directory outDir,
  }) async {
    final bgr = cv.imdecode(jpgBytes, cv.IMREAD_COLOR);
    final rgba = matToRgba(bgr);
    bgr.dispose();

    final quad = s_core.ScannerCv.detectDocument(rgba);
    final pixelQuad = (quad ?? s_core.Quad.fullFrame()).scale(
      rgba.width - 1.0,
      rgba.height - 1.0,
    );
    final flat = s_core.ScannerCv.warp(rgba, pixelQuad);

    const filters = [
      (s_core.ScanFilter.auto_, 'auto'),
      (s_core.ScanFilter.magicColor, 'magicColor'),
      (s_core.ScanFilter.blackWhite, 'blackWhite'),
      (s_core.ScanFilter.shadowRemoval, 'shadowRemoval'),
    ];

    if (!outDir.existsSync()) outDir.createSync(recursive: true);

    for (final (filter, label) in filters) {
      final filtered = s_core.ScannerCv.applyFilter(flat, filter);
      final jpg = s_core.ScannerCv.encodeJpeg(filtered, 92);
      final outFile = File('${outDir.path}/${name}_$label.jpg');
      await outFile.writeAsBytes(jpg);
    }
  }
}
