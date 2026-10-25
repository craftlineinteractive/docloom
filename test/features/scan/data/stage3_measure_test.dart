// ignore_for_file: avoid_print
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'package:docloom/features/scan/domain/quad.dart';
import 'package:docloom/features/scan/data/opencv_transform_ops.dart';
import 'package:docloom/features/scan/data/filter_recipes.dart';

double computeLaplacianVariance(cv.Mat mat) {
  final cv.Mat gray = mat.channels == 1 ? mat.clone() : cv.cvtColor(mat, cv.COLOR_BGR2GRAY);
  final lap = cv.laplacian(gray, cv.MatType.CV_16S);
  final (_, stddev) = cv.meanStdDev(lap);
  final dev = stddev.val1;
  lap.dispose();
  gray.dispose();
  return dev * dev;
}

void main() {
  test('Stage 3 Baseline Measurements', () {
    const fixturePath = 'test/fixtures/documents/01_baseline.jpg';
    final rawMat = cv.imread(fixturePath, flags: cv.IMREAD_COLOR);
    expect(rawMat.isEmpty, isFalse);

    final rawW = rawMat.width;
    final rawH = rawMat.height;
    final rawVar = computeLaplacianVariance(rawMat);

    // Warp with default quad
    final quad = Quad.defaultInset();
    final warpedMat = OpencvTransformOps.warpAndRotate(rawMat, quad, 0);
    final warpW = warpedMat.width;
    final warpH = warpedMat.height;
    final warpVar = computeLaplacianVariance(warpedMat);

    // Filter auto_enhance
    final enhancedMat = FilterRecipes.autoEnhance(warpedMat);
    final enhanceVar = computeLaplacianVariance(enhancedMat);

    // Save to JPEG quality 95
    final tempDst = '${Directory.systemTemp.path}/measure_stage3_out.jpg';
    final params = cv.VecI32.fromList([cv.IMWRITE_JPEG_QUALITY, 95]);
    cv.imwrite(tempDst, enhancedMat, params: params);
    params.dispose();

    final savedMat = cv.imread(tempDst, flags: cv.IMREAD_COLOR);
    final savedVar = computeLaplacianVariance(savedMat);
    savedMat.dispose();
    File(tempDst).deleteSync();

    print('\n========================================================================');
    print('| STAGE 3 PREAMBLE MEASUREMENTS (01_baseline.jpg)                      |');
    print('------------------------------------------------------------------------');
    print('| Metric                              | Value                          |');
    print('------------------------------------------------------------------------');
    print('| Camera photo size                   | ${rawW}x$rawH (12 MP)              |');
    print('| ResolutionPreset (all scanQuality)  | ResolutionPreset.max           |');
    print('| scanQuality standard cap            | 2000 px long side              |');
    print('| scanQuality high cap                | 3000 px long side              |');
    print('| scanQuality max cap                 | 4000 px long side              |');
    print('| Size after importCapture            | ${rawW}x$rawH                        |');
    print('| Warp output size (raw quad)         | ${warpW}x$warpH                        |');
    print('| Number of resamples/re-encodes      | 1 (single JPEG at quality 95)  |');
    print('| JPEG quality                        | 95                             |');
    print('| Laplacian variance: Raw capture     | ${rawVar.toStringAsFixed(2)}                        |');
    print('| Laplacian variance: After warp      | ${warpVar.toStringAsFixed(2)}                        |');
    print('| Laplacian variance: After filter    | ${enhanceVar.toStringAsFixed(2)}                        |');
    print('| Laplacian variance: Saved JPEG (95) | ${savedVar.toStringAsFixed(2)}                        |');
    print('========================================================================\n');

    rawMat.dispose();
    warpedMat.dispose();
    enhancedMat.dispose();
  });
}
