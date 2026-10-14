import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'package:docloom/core/constants/app_config.dart';
import 'package:docloom/features/scan/data/opencv_image_engine.dart';
import 'package:docloom/features/scan/domain/quad.dart';

void main() {
  late Directory tempDir;
  late OpencvImageEngine engine;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('opencv_engine_test_');
    engine = const OpencvImageEngine();
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('renderPage with true quad produces near-rectangular output and rotation 90 swaps dimensions', () async {
    final srcPath = '${tempDir.path}/fixture.jpg';
    final dstPath = '${tempDir.path}/rendered.jpg';
    final dstRotPath = '${tempDir.path}/rendered_rot.jpg';

    final bg = cv.Mat.fromScalar(800, 600, cv.MatType.CV_8UC3, cv.Scalar(128, 128, 128, 0));
    final tl = cv.Point(100, 120);
    final tr = cv.Point(500, 100);
    final br = cv.Point(510, 690);
    final bl = cv.Point(90, 710);

    final poly = cv.VecVecPoint.fromVecPoint(cv.VecPoint.fromList([tl, tr, br, bl]));
    cv.fillPoly(bg, poly, cv.Scalar(255, 255, 255, 0));

    cv.circle(bg, cv.Point(130, 150), 8, cv.Scalar(0, 0, 0, 0), thickness: -1);
    cv.circle(bg, cv.Point(470, 130), 8, cv.Scalar(0, 0, 0, 0), thickness: -1);
    cv.circle(bg, cv.Point(480, 660), 8, cv.Scalar(0, 0, 0, 0), thickness: -1);
    cv.circle(bg, cv.Point(120, 680), 8, cv.Scalar(0, 0, 0, 0), thickness: -1);

    cv.imwrite(srcPath, bg);
    bg.dispose();
    poly.dispose();

    const quad = Quad(
      topLeft: Offset(100 / 600, 120 / 800),
      topRight: Offset(500 / 600, 100 / 800),
      bottomRight: Offset(510 / 600, 690 / 800),
      bottomLeft: Offset(90 / 600, 710 / 800),
    );

    await engine.renderPage(
      srcPath: srcPath,
      quad: quad,
      rotation: 0,
      filterId: 'original',
      dstPath: dstPath,
    );

    final result = cv.imread(dstPath, flags: cv.IMREAD_COLOR);
    final w = result.width;
    final h = result.height;
    expect((w - 420).abs() / 420, lessThan(0.03));
    expect((h - 590).abs() / 590, lessThan(0.03));

    final bytes = result.data;
    bool isWhite(int x, int y) {
      final idx = (y * w + x) * 3;
      return bytes[idx] > 200 && bytes[idx + 1] > 200 && bytes[idx + 2] > 200;
    }

    expect(isWhite(0, 0), isTrue, reason: 'Top-left corner is white');
    expect(isWhite(w - 1, 0), isTrue, reason: 'Top-right corner is white');
    expect(isWhite(w - 1, h - 1), isTrue, reason: 'Bottom-right corner is white');
    expect(isWhite(0, h - 1), isTrue, reason: 'Bottom-left corner is white');
    result.dispose();

    await engine.renderPage(
      srcPath: srcPath,
      quad: quad,
      rotation: 90,
      filterId: 'original',
      dstPath: dstRotPath,
    );

    final rotResult = cv.imread(dstRotPath, flags: cv.IMREAD_COLOR);
    expect(rotResult.width, equals(h));
    expect(rotResult.height, equals(w));
    rotResult.dispose();
  });

  test('A generated 12-megapixel image is downscaled to the max side', () async {
    final srcPath = '${tempDir.path}/12mp.jpg';
    final dstPath = '${tempDir.path}/imported.jpg';
    final previewPath = '${tempDir.path}/preview.jpg';

    // 4000 x 3000 = 12 MP
    final mat = cv.Mat.fromScalar(3000, 4000, cv.MatType.CV_8UC3, cv.Scalar(100, 150, 200, 0));
    cv.imwrite(srcPath, mat);
    mat.dispose();

    final size = await engine.importCapture(srcPath: srcPath, dstPath: dstPath);
    expect(size.width, equals(AppConfig.scanMaxSide));
    expect(size.height, equals(2250));

    final imported = cv.imread(dstPath, flags: cv.IMREAD_COLOR);
    expect(imported.width, equals(AppConfig.scanMaxSide));
    expect(imported.height, equals(2250));
    imported.dispose();

    await engine.makePreview(srcPath: dstPath, dstPath: previewPath);
    final preview = cv.imread(previewPath, flags: cv.IMREAD_COLOR);
    expect(preview.width, equals(AppConfig.previewMaxSide));
    expect(preview.height, equals(960));
    preview.dispose();
  });

  test('importCapture with test/fixtures/exif_rotated.jpg (NOT VERIFIED if missing)', () async {
    final fixture = File('test/fixtures/exif_rotated.jpg');
    if (!await fixture.exists()) {
      markTestSkipped('test/fixtures/exif_rotated.jpg is missing - NOT VERIFIED');
      return;
    }

    final dst1 = '${tempDir.path}/exif_imported1.jpg';
    final dst2 = '${tempDir.path}/exif_imported2.jpg';
    final s1 = await engine.importCapture(srcPath: fixture.path, dstPath: dst1);
    final s2 = await engine.importCapture(srcPath: dst1, dstPath: dst2);
    expect(s2.width, equals(s1.width));
    expect(s2.height, equals(s1.height));
  });

  test('unsupported filter throws UnsupportedError', () async {
    expect(
      () => engine.renderPage(
        srcPath: '${tempDir.path}/missing.jpg',
        quad: Quad.defaultInset(),
        rotation: 0,
        filterId: 'bw',
        dstPath: '${tempDir.path}/out.jpg',
      ),
      throwsA(isA<UnsupportedError>()),
    );
  });
}
