// ignore_for_file: avoid_print
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'package:docloom/features/scan/data/opencv_edge_detector.dart';

void main() {
  late Directory tempDir;
  late OpencvEdgeDetector detector;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('detector_test_');
    detector = OpencvEdgeDetector();
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  test('Blank image returns null', () async {
    final blankPath = '${tempDir.path}/blank.jpg';
    final mat = cv.Mat.fromScalar(600, 800, cv.MatType.CV_8UC3, cv.Scalar(200, 200, 200, 0));
    cv.imwrite(blankPath, mat);
    mat.dispose();

    final result = await detector.detectFromFile(blankPath);
    expect(result, isNull);
  });

  test('Synthetic clean fixture is detected accurately', () async {
    final path = '${tempDir.path}/clean.jpg';
    final bg = cv.Mat.fromScalar(800, 600, cv.MatType.CV_8UC3, cv.Scalar(40, 40, 40, 0));
    final poly = cv.VecVecPoint.fromVecPoint(cv.VecPoint.fromList([
      cv.Point(100, 100), cv.Point(500, 100), cv.Point(500, 700), cv.Point(100, 700),
    ]));
    cv.fillPoly(bg, poly, cv.Scalar(240, 240, 240, 0));
    cv.imwrite(path, bg);
    bg.dispose(); poly.dispose();

    final quad = await detector.detectFromFile(path);
    expect(quad, isNotNull);
    expect(quad!.tl.dx, closeTo(100 / 600, 0.05));
    expect(quad.tl.dy, closeTo(100 / 800, 0.05));
  });

  test('Synthetic rotated fixture is detected', () async {
    final path = '${tempDir.path}/rotated.jpg';
    final bg = cv.Mat.fromScalar(800, 600, cv.MatType.CV_8UC3, cv.Scalar(30, 30, 30, 0));
    final poly = cv.VecVecPoint.fromVecPoint(cv.VecPoint.fromList([
      cv.Point(200, 100), cv.Point(520, 250), cv.Point(400, 720), cv.Point(80, 570),
    ]));
    cv.fillPoly(bg, poly, cv.Scalar(235, 235, 235, 0));
    cv.imwrite(path, bg);
    bg.dispose(); poly.dispose();

    final quad = await detector.detectFromFile(path);
    expect(quad, isNotNull);
    expect(quad!.isValid, isTrue);
  });

  test('Synthetic low contrast fixture is detected', () async {
    final path = '${tempDir.path}/low_contrast.jpg';
    final bg = cv.Mat.fromScalar(800, 600, cv.MatType.CV_8UC3, cv.Scalar(130, 130, 130, 0));
    final poly = cv.VecVecPoint.fromVecPoint(cv.VecPoint.fromList([
      cv.Point(120, 120), cv.Point(480, 120), cv.Point(480, 680), cv.Point(120, 680),
    ]));
    cv.fillPoly(bg, poly, cv.Scalar(190, 190, 190, 0));
    cv.imwrite(path, bg);
    bg.dispose(); poly.dispose();

    final quad = await detector.detectFromFile(path);
    expect(quad, isNotNull);
  });

  test('Synthetic book cover on patterned desk is detected', () async {
    final path = '${tempDir.path}/book_pattern.jpg';
    final bg = cv.Mat.fromScalar(800, 600, cv.MatType.CV_8UC3, cv.Scalar(50, 50, 50, 0));
    for (var i = 0; i < 600; i += 20) {
      cv.line(bg, cv.Point(i, 0), cv.Point(i, 800), cv.Scalar(75, 75, 75, 0));
    }
    final poly = cv.VecVecPoint.fromVecPoint(cv.VecPoint.fromList([
      cv.Point(150, 150), cv.Point(450, 150), cv.Point(450, 650), cv.Point(150, 650),
    ]));
    cv.fillPoly(bg, poly, cv.Scalar(20, 40, 200, 0)); // dark reddish book cover
    cv.imwrite(path, bg);
    bg.dispose(); poly.dispose();

    final quad = await detector.detectFromFile(path);
    expect(quad, isNotNull);
  });

  test('detectFromGray works with grayscale bytes', () async {
    final bg = cv.Mat.fromScalar(400, 300, cv.MatType.CV_8UC1, cv.Scalar(40, 0, 0, 0));
    final poly = cv.VecVecPoint.fromVecPoint(cv.VecPoint.fromList([
      cv.Point(50, 50), cv.Point(250, 50), cv.Point(250, 350), cv.Point(50, 350),
    ]));
    cv.fillPoly(bg, poly, cv.Scalar(240, 0, 0, 0));
    final bytes = bg.data;
    final quad = await detector.detectFromGray(bytes, 300, 400);
    bg.dispose(); poly.dispose();
    expect(quad, isNotNull);
  });

  test('Runtime under 400 ms at preview size', () async {
    final path = '${tempDir.path}/runtime_preview.jpg';
    final bg = cv.Mat.fromScalar(640, 480, cv.MatType.CV_8UC3, cv.Scalar(60, 60, 60, 0));
    final poly = cv.VecVecPoint.fromVecPoint(cv.VecPoint.fromList([
      cv.Point(80, 80), cv.Point(400, 80), cv.Point(400, 560), cv.Point(80, 560),
    ]));
    cv.fillPoly(bg, poly, cv.Scalar(230, 230, 230, 0));
    cv.imwrite(path, bg);
    bg.dispose(); poly.dispose();

    final sw = Stopwatch()..start();
    final quad = await detector.detectFromFile(path);
    sw.stop();

    print('Runtime at preview size: ${sw.elapsedMilliseconds} ms');
    expect(quad, isNotNull);
    expect(sw.elapsedMilliseconds, lessThan(400), reason: 'Runtime must be under 400 ms');
  });
}
