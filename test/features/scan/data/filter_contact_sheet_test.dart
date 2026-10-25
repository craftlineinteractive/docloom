// ignore_for_file: avoid_print
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'package:docloom/features/scan/domain/quad.dart';
import 'package:docloom/features/scan/data/opencv_transform_ops.dart';
import 'package:docloom/features/scan/data/filter_recipes.dart';

void main() {
  test('Generate filter contact sheets and measure 12 MP render time', () {
    final reportDir = Directory('build/filter_report');
    if (!reportDir.existsSync()) reportDir.createSync(recursive: true);

    const testFixtures = [
      'test/fixtures/documents/01_baseline.jpg',
      'test/fixtures/documents/08_shadow_page.jpg',
      'test/fixtures/documents/10_dim_light.jpg',
    ];

    for (final fixPath in testFixtures) {
      final name = fixPath.split('/').last.split('.').first;
      final rawMat = cv.imread(fixPath, flags: cv.IMREAD_COLOR);
      if (rawMat.isEmpty) continue;

      final quad = Quad.defaultInset();
      final plainWarp = OpencvTransformOps.warpAndRotate(rawMat, quad, 0, maxSide: 800);

      final cells = <cv.Mat>[];
      // 1. Raw original resized to cell size
      cells.add(cv.resize(rawMat, (plainWarp.width, plainWarp.height), interpolation: cv.INTER_AREA));
      // 2. Plain warp
      cells.add(plainWarp.clone());
      // 3. Grayscale
      cells.add(FilterRecipes.grayscale(plainWarp));
      // 4. Black & white
      cells.add(FilterRecipes.blackWhite(plainWarp));
      // 5. Auto enhance
      cells.add(FilterRecipes.autoEnhance(plainWarp));
      // 6. Vivid light
      cells.add(FilterRecipes.vividLight(plainWarp));

      // Compose 2 rows x 3 columns
      final r1a = cv.hconcat(cells[0], cells[1]);
      final row1 = cv.hconcat(r1a, cells[2]);
      r1a.dispose();

      final r2a = cv.hconcat(cells[3], cells[4]);
      final row2 = cv.hconcat(r2a, cells[5]);
      r2a.dispose();

      final contactSheet = cv.vconcat(row1, row2);
      row1.dispose();
      row2.dispose();

      final outPath = 'build/filter_report/${name}_filters.png';
      cv.imwrite(outPath, contactSheet);
      contactSheet.dispose();

      for (final c in cells) {
        c.dispose();
      }
      plainWarp.dispose();
      rawMat.dispose();
      print('Wrote contact sheet: $outPath');
    }

    // Measure full 12 MP (3000x4000) render time through the single pipeline
    final fullMat = cv.imread('test/fixtures/documents/01_baseline.jpg', flags: cv.IMREAD_COLOR);
    expect(fullMat.isEmpty, isFalse);

    final sw = Stopwatch()..start();
    final quad = Quad.defaultInset();
    // warp (INTER_CUBIC) -> filter -> single JPEG encode
    final warped = OpencvTransformOps.warpAndRotate(fullMat, quad, 0);
    final filtered = FilterRecipes.vividLight(warped);
    final params = cv.VecI32.fromList([cv.IMWRITE_JPEG_QUALITY, 95]);
    final (ok, bytes) = cv.imencode('.jpg', filtered, params: params);
    sw.stop();

    expect(ok, isTrue);
    expect(bytes.length, greaterThan(0));
    final renderMs = sw.elapsedMilliseconds;
    print('\n========================================================================');
    print('| 12 MP (3000x4000) FULL PIPELINE RENDER TIME BENCHMARK                |');
    print('------------------------------------------------------------------------');
    print('| Image: 01_baseline.jpg (12 MP, ${fullMat.width}x${fullMat.height})                  |');
    print('| Output size: ${warped.width}x${warped.height}                                      |');
    print('| Total time (warp + vivid_light + JPEG 95 encode): $renderMs ms (${(renderMs / 1000).toStringAsFixed(3)} s) |');
    print('| Target: < 2000 ms (< 2.0 s) -> ${renderMs < 2000 ? "PASS" : "FAIL"}                                |');
    print('========================================================================\n');

    expect(renderMs, lessThan(2000));

    params.dispose();
    filtered.dispose();
    warped.dispose();
    fullMat.dispose();
  });
}
