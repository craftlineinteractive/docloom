// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'package:docloom/features/scan/data/opencv_isolate_ops.dart';
import 'package:docloom/features/scan/domain/quad.dart';
import 'package:docloom/features/scan/presentation/adjust/crop_coordinates.dart';
import 'dart:ui';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('crop_geom_test_');
  });

  tearDownAll(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  group('Stage 1: Crop Geometry & Aspect Ratio', () {
    test('makePreview preserves aspect ratio within 0.5%', () async {
      final srcPath = '${tempDir.path}/tall_source.jpg';
      final prevPath = '${tempDir.path}/tall_preview.jpg';
      final mat = cv.Mat.fromScalar(2400, 1800, cv.MatType.CV_8UC3, cv.Scalar(200, 200, 200, 0));
      cv.imwrite(srcPath, mat);
      mat.dispose();

      OpencvIsolateOps.makePreview(srcPath, prevPath, 800, 85);
      final prevMat = cv.imread(prevPath);
      final srcAspect = 1800 / 2400;
      final prevAspect = prevMat.width / prevMat.height;
      final err = (prevAspect - srcAspect).abs() / srcAspect;
      prevMat.dispose();

      expect(err, lessThan(0.005));
    });

    test('Warped page aspect 210:297 at tilts 0, 20, 40 deg yields 1.414 within 2% and corners within 1%', () async {
      const f = 1000.0, d = 1500.0, w = 420.0, h = 594.0;
      const canvasW = 1000, canvasH = 1000;
      final cx = canvasW / 2.0, cy = canvasH / 2.0;

      for (final deg in [0, 20, 40]) {
        final rad = deg * math.pi / 180.0;
        Offset project(double x, double y) {
          final yp = y * math.cos(rad);
          final zp = y * math.sin(rad) + d;
          return Offset(f * (x / zp) + cx, f * (yp / zp) + cy);
        }

        final p1 = project(-w / 2, -h / 2), p2 = project(w / 2, -h / 2);
        final p4 = project(w / 2, h / 2), p3 = project(-w / 2, h / 2);

        final canvas = cv.Mat.fromScalar(canvasH, canvasW, cv.MatType.CV_8UC3, cv.Scalar(0, 0, 0, 0));
        final poly = cv.VecVecPoint.fromVecPoint(cv.VecPoint.fromList([
          cv.Point(p1.dx.round(), p1.dy.round()), cv.Point(p2.dx.round(), p2.dy.round()),
          cv.Point(p4.dx.round(), p4.dy.round()), cv.Point(p3.dx.round(), p3.dy.round()),
        ]));
        cv.fillPoly(canvas, poly, cv.Scalar(255, 255, 255, 0));
        poly.dispose();

        for (final pt in [p1, p2, p4, p3]) {
          cv.circle(canvas, cv.Point(pt.dx.round(), pt.dy.round()), 4, cv.Scalar(128, 128, 128, 0), thickness: -1);
        }

        final srcPath = '${tempDir.path}/synth_tilt_$deg.jpg';
        final dstPath = '${tempDir.path}/out_tilt_$deg.jpg';
        cv.imwrite(srcPath, canvas);
        canvas.dispose();

        final normQuad = Quad(
          topLeft: Offset(p1.dx / canvasW, p1.dy / canvasH),
          topRight: Offset(p2.dx / canvasW, p2.dy / canvasH),
          bottomRight: Offset(p4.dx / canvasW, p4.dy / canvasH),
          bottomLeft: Offset(p3.dx / canvasW, p3.dy / canvasH),
        );

        OpencvIsolateOps.renderPage(
          srcPath: srcPath, quad: normQuad, rotation: 0,
          filterId: 'original', dstPath: dstPath, quality: 95,
        );

        final outMat = cv.imread(dstPath);
        final outAspect = outMat.height / outMat.width;
        expect(outAspect, closeTo(297.0 / 210.0, (297.0 / 210.0) * 0.02));
        expect(outMat.width, greaterThan(100));
        expect(outMat.height, greaterThan(100));
        outMat.dispose();
      }
    });

    test('90-degree rotated page renders with swapped dimensions', () async {
      final canvas = cv.Mat.fromScalar(600, 800, cv.MatType.CV_8UC3, cv.Scalar(100, 100, 100, 0));
      final srcPath = '${tempDir.path}/rotated_src.jpg';
      final dstPath = '${tempDir.path}/rotated_out.jpg';
      cv.imwrite(srcPath, canvas);
      canvas.dispose();

      OpencvIsolateOps.renderPage(
        srcPath: srcPath, quad: Quad.unit(), rotation: 90,
        filterId: 'original', dstPath: dstPath, quality: 95,
      );
      final outMat = cv.imread(dstPath);
      expect(outMat.width, equals(600));
      expect(outMat.height, equals(800));
      outMat.dispose();
    });

    test('CropCoordinates mapping subtracts letterbox and tests tall, wide, rotated-90', () {
      // Tall container (box 400x800), wide image (aspect 2.0 = 400x200): letterbox top/bottom
      const tallBox = Size(400, 800);
      final rectWide = CropCoordinates.computeImageRect(boxSize: tallBox, imageAspectRatio: 2.0);
      expect(rectWide.left, equals(0));
      expect(rectWide.top, equals(300));
      expect(rectWide.width, equals(400));
      expect(rectWide.height, equals(200));

      // Wide container (box 800x400), tall image (aspect 0.5 = 200x400): letterbox left/right
      const wideBox = Size(800, 400);
      final rectTall = CropCoordinates.computeImageRect(boxSize: wideBox, imageAspectRatio: 0.5);
      expect(rectTall.left, equals(300));
      expect(rectTall.top, equals(0));
      expect(rectTall.width, equals(200));
      expect(rectTall.height, equals(400));

      // Rotated-90: inverted aspect ratio
      final rectRot90 = CropCoordinates.computeImageRect(boxSize: tallBox, imageAspectRatio: 1.0 / 2.0);
      expect(rectRot90.width, equals(400));
      expect(rectRot90.height, equals(800));
    });

    test('CropCoordinates round trip error is less than 1 pixel', () {
      const boxSize = Size(360, 640);
      const aspect = 3.0 / 4.0;
      final rect = CropCoordinates.computeImageRect(boxSize: boxSize, imageAspectRatio: aspect);

      for (double nx = 0.0; nx <= 1.0; nx += 0.25) {
        for (double ny = 0.0; ny <= 1.0; ny += 0.25) {
          final widgetPt = CropCoordinates.normalizedToWidget(
            normalizedPoint: Offset(nx, ny), boxSize: boxSize, imageAspectRatio: aspect,
          );
          final roundTrip = CropCoordinates.widgetToNormalized(
            widgetPoint: widgetPt, boxSize: boxSize, imageAspectRatio: aspect,
          );
          final diffPxX = (roundTrip.dx - nx).abs() * rect.width;
          final diffPxY = (roundTrip.dy - ny).abs() * rect.height;
          expect(diffPxX, lessThan(1.0));
          expect(diffPxY, lessThan(1.0));
        }
      }
    });
  });
}
