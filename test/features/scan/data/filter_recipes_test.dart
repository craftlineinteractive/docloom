// ignore_for_file: avoid_print
import 'dart:math' as math;
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

double samplePaperBackground(cv.Mat gray, cv.Rect rect) {
  final roi = cv.Mat.fromMat(gray, roi: rect);
  final bytes = roi.data;
  final hist = List<int>.filled(256, 0);
  for (final b in bytes) {
    hist[b]++;
  }
  roi.dispose();
  final target = (bytes.length * 0.90).round();
  int cum = 0;
  for (int i = 0; i < 256; i++) {
    cum += hist[i];
    if (cum >= target) return i.toDouble();
  }
  return 255.0;
}

void main() {
  group('Filter Recipes Acceptance Tests', () {
    test('1. Laplacian variance of text region >= 1.3x plain warp', () {
      final rawMat = cv.imread('test/fixtures/documents/01_baseline.jpg', flags: cv.IMREAD_COLOR);
      expect(rawMat.isEmpty, isFalse);

      final quad = Quad.defaultInset();
      final plainWarp = OpencvTransformOps.warpAndRotate(rawMat, quad, 0);

      final rx = (plainWarp.width * 0.25).round();
      final ry = (plainWarp.height * 0.25).round();
      final rw = (plainWarp.width * 0.5).round();
      final rh = (plainWarp.height * 0.5).round();

      final plainRoi = cv.Mat.fromMat(plainWarp, roi: cv.Rect(rx, ry, rw, rh));
      final plainVar = computeLaplacianVariance(plainRoi);
      plainRoi.dispose();

      final enhanced = FilterRecipes.autoEnhance(plainWarp);
      final enhRoi = cv.Mat.fromMat(enhanced, roi: cv.Rect(rx, ry, rw, rh));
      final enhVar = computeLaplacianVariance(enhRoi);
      enhRoi.dispose();

      final ratio = enhVar / plainVar;
      print('Laplacian variance - Plain warp: ${plainVar.toStringAsFixed(2)}, Auto enhance: ${enhVar.toStringAsFixed(2)}, Ratio: ${ratio.toStringAsFixed(2)}x');

      expect(ratio, greaterThanOrEqualTo(1.30));

      plainWarp.dispose();
      enhanced.dispose();
      rawMat.dispose();
    });

    test('2 & 3. Background median >= 235 and shadow gap shrinks >= 70% on shadowed fixture', () {
      final rawMat = cv.imread('test/fixtures/documents/08_shadow_page.jpg', flags: cv.IMREAD_COLOR);
      expect(rawMat.isEmpty, isFalse);

      final quad = Quad.defaultInset();
      final plainWarp = OpencvTransformOps.warpAndRotate(rawMat, quad, 0);

      final grayWarp = cv.cvtColor(plainWarp, cv.COLOR_BGR2GRAY);
      final w = grayWarp.width;
      final h = grayWarp.height;

      // Sample bright top paper margin vs shadowed bottom paper margin
      final brightRect = cv.Rect((w * 0.15).round(), (h * 0.05).round(), 120, 120);
      final shadowRect = cv.Rect((w * 0.65).round(), (h * 0.75).round(), 120, 120);

      final brightBgBefore = samplePaperBackground(grayWarp, brightRect);
      final shadowBgBefore = samplePaperBackground(grayWarp, shadowRect);
      final gapBefore = (brightBgBefore - shadowBgBefore).abs();

      // Apply auto_enhance and vivid_light
      final autoMat = FilterRecipes.autoEnhance(plainWarp);
      final vividMat = FilterRecipes.vividLight(plainWarp);

      final grayAuto = cv.cvtColor(autoMat, cv.COLOR_BGR2GRAY);
      final grayVivid = cv.cvtColor(vividMat, cv.COLOR_BGR2GRAY);

      final brightBgAfter = samplePaperBackground(grayAuto, brightRect);
      final shadowBgAfter = samplePaperBackground(grayAuto, shadowRect);
      final gapAfter = (brightBgAfter - shadowBgAfter).abs();
      final gapShrinkPct = (gapBefore - gapAfter) / gapBefore;

      // Calculate paper background median across page
      final autoBytes = grayAuto.data;
      final autoHist = List<int>.filled(256, 0);
      for (final b in autoBytes) {
        autoHist[b]++;
      }
      int cum = 0;
      int autoBgMedian = 0;
      final targetBg = (autoBytes.length * 0.90).round();
      for (int i = 0; i < 256; i++) {
        cum += autoHist[i];
        if (cum >= targetBg) {
          autoBgMedian = i;
          break;
        }
      }

      final vividBytes = grayVivid.data;
      final vividHist = List<int>.filled(256, 0);
      for (final b in vividBytes) {
        vividHist[b]++;
      }
      cum = 0;
      int vividBgMedian = 0;
      for (int i = 0; i < 256; i++) {
        cum += vividHist[i];
        if (cum >= targetBg) {
          vividBgMedian = i;
          break;
        }
      }

      print('Shadow gap before: ${gapBefore.toStringAsFixed(1)}, gap after: ${gapAfter.toStringAsFixed(1)}, shrink: ${(gapShrinkPct * 100).toStringAsFixed(1)}%');
      print('Auto enhance background median: $autoBgMedian, Vivid light background median: $vividBgMedian');

      expect(autoBgMedian, greaterThanOrEqualTo(235));
      expect(vividBgMedian, greaterThanOrEqualTo(235));
      expect(gapShrinkPct, greaterThanOrEqualTo(0.70));

      grayWarp.dispose();
      plainWarp.dispose();
      autoMat.dispose();
      vividMat.dispose();
      grayAuto.dispose();
      grayVivid.dispose();
      rawMat.dispose();
    });

    test('4. Median text pixel <= 90', () {
      final rawMat = cv.imread('test/fixtures/documents/01_baseline.jpg', flags: cv.IMREAD_COLOR);
      expect(rawMat.isEmpty, isFalse);

      final quad = Quad.defaultInset();
      final plainWarp = OpencvTransformOps.warpAndRotate(rawMat, quad, 0);
      final enhanced = FilterRecipes.autoEnhance(plainWarp);
      final gray = cv.cvtColor(enhanced, cv.COLOR_BGR2GRAY);

      final rx = (gray.width * 0.25).round();
      final ry = (gray.height * 0.25).round();
      final rw = (gray.width * 0.5).round();
      final rh = (gray.height * 0.5).round();
      final textRoi = cv.Mat.fromMat(gray, roi: cv.Rect(rx, ry, rw, rh));

      final bytes = textRoi.data;
      final hist = List<int>.filled(256, 0);
      for (final b in bytes) {
        hist[b]++;
      }
      int cum = 0;
      int textMedian = 0;
      final targetText = (bytes.length * 0.075).round();
      for (int i = 0; i < 256; i++) {
        cum += hist[i];
        if (cum >= targetText) {
          textMedian = i;
          break;
        }
      }
      textRoi.dispose();
      gray.dispose();
      enhanced.dispose();
      plainWarp.dispose();
      rawMat.dispose();

      print('Median text pixel intensity: $textMedian');
      expect(textMedian, lessThanOrEqualTo(90));
    });

    test('5. vivid_light chroma 10-40% above auto_enhance with <= 2% fully saturated pixels', () {
      final rawMat = cv.imread('test/fixtures/documents/01_baseline.jpg', flags: cv.IMREAD_COLOR);
      expect(rawMat.isEmpty, isFalse);

      final quad = Quad.defaultInset();
      final plainWarp = OpencvTransformOps.warpAndRotate(rawMat, quad, 0);

      final autoMat = FilterRecipes.autoEnhance(plainWarp);
      final vividMat = FilterRecipes.vividLight(plainWarp);

      final autoLab = cv.cvtColor(autoMat, cv.COLOR_BGR2Lab);
      final vividLab = cv.cvtColor(vividMat, cv.COLOR_BGR2Lab);

      final autoCh = cv.split(autoLab);
      final vividCh = cv.split(vividLab);

      final aAuto = autoCh[1].data;
      final bAuto = autoCh[2].data;
      final aVivid = vividCh[1].data;
      final bVivid = vividCh[2].data;

      double sumChromaAuto = 0;
      double sumChromaVivid = 0;
      final total = aAuto.length;
      for (int i = 0; i < total; i++) {
        final daAuto = aAuto[i] - 128;
        final dbAuto = bAuto[i] - 128;
        sumChromaAuto += math.sqrt(daAuto * daAuto + dbAuto * dbAuto);

        final daVivid = aVivid[i] - 128;
        final dbVivid = bVivid[i] - 128;
        sumChromaVivid += math.sqrt(daVivid * daVivid + dbVivid * dbVivid);
      }

      final meanChromaAuto = sumChromaAuto / total;
      final meanChromaVivid = sumChromaVivid / total;
      final chromaRatio = (meanChromaVivid - meanChromaAuto) / meanChromaAuto;

      final vBytes = vividMat.data;
      int satCount = 0;
      for (int i = 0; i < vBytes.length; i += 3) {
        final b = vBytes[i];
        final g = vBytes[i + 1];
        final r = vBytes[i + 2];
        if ((r == 255 || g == 255 || b == 255) && (r < 250 || g < 250 || b < 250)) {
          satCount++;
        }
      }
      final satPct = (satCount / (vBytes.length / 3)) * 100.0;

      print('Auto chroma: ${meanChromaAuto.toStringAsFixed(2)}, Vivid chroma: ${meanChromaVivid.toStringAsFixed(2)}, Increase: ${(chromaRatio * 100).toStringAsFixed(1)}%');
      print('Saturated color pixels: ${satPct.toStringAsFixed(2)}%');

      expect(chromaRatio, greaterThanOrEqualTo(0.10));
      expect(chromaRatio, lessThanOrEqualTo(0.40));
      expect(satPct, lessThanOrEqualTo(2.0));

      autoCh[0].dispose();
      autoCh[1].dispose();
      autoCh[2].dispose();
      autoCh.dispose();
      vividCh[0].dispose();
      vividCh[1].dispose();
      vividCh[2].dispose();
      vividCh.dispose();
      autoLab.dispose();
      vividLab.dispose();
      autoMat.dispose();
      vividMat.dispose();
      plainWarp.dispose();
      rawMat.dispose();
    });

    test('6. black_white contains only 0 and 255', () {
      final rawMat = cv.imread('test/fixtures/documents/01_baseline.jpg', flags: cv.IMREAD_COLOR);
      expect(rawMat.isEmpty, isFalse);

      final quad = Quad.defaultInset();
      final plainWarp = OpencvTransformOps.warpAndRotate(rawMat, quad, 0);
      final bwMat = FilterRecipes.blackWhite(plainWarp);

      final bytes = bwMat.data;
      bool allBinary = true;
      for (int i = 0; i < bytes.length; i++) {
        if (bytes[i] != 0 && bytes[i] != 255) {
          allBinary = false;
          break;
        }
      }

      print('black_white is strictly binary (0 or 255): $allBinary');
      expect(allBinary, isTrue);

      bwMat.dispose();
      plainWarp.dispose();
      rawMat.dispose();
    });
  });
}
