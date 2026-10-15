// ignore_for_file: avoid_print
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'package:docloom/features/scan/data/filter_recipes.dart';
import 'package:docloom/features/scan/data/preview_lru_cache.dart';
import 'filter_test_fixture.dart';

void main() {
  test('black_white contains only 0 and 255', () {
    final fixture = createTestFixture();
    final result = FilterRecipes.blackWhite(fixture);
    final data = result.data;
    int zeros = 0, twoFiftyFives = 0, invalid = 0;
    for (final byte in data) {
      if (byte == 0) {
        zeros++;
      } else if (byte == 255) {
        twoFiftyFives++;
      } else {
        invalid++;
      }
    }
    print('black_white: zeros=$zeros, 255s=$twoFiftyFives, invalid=$invalid');
    expect(invalid, equals(0));
    expect(zeros, greaterThan(0));
    expect(twoFiftyFives, greaterThan(0));
    result.dispose();
    fixture.dispose();
  });

  test('grayscale: R=G=B everywhere', () {
    final fixture = createTestFixture();
    final result = FilterRecipes.grayscale(fixture);
    final data = result.data;
    int diffs = 0;
    for (int i = 0; i < data.length; i += 3) {
      if (data[i] != data[i + 1] || data[i + 1] != data[i + 2]) diffs++;
    }
    print('grayscale: total pixels=${data.length ~/ 3}, diffs=$diffs');
    expect(diffs, equals(0));
    result.dispose();
    fixture.dispose();
  });

  test('auto_enhance shrinks brightness gap by >= 50% and keeps text darker than background', () {
    final fixture = createTestFixture();
    double initShadow = 0, initLit = 0;
    for (int x = 20; x < 80; x++) {
      final v = fixture.at<cv.Vec3b>(20, x);
      initShadow += (v.val1 + v.val2 + v.val3) / 3.0;
    }
    for (int x = 120; x < 180; x++) {
      final v = fixture.at<cv.Vec3b>(20, x);
      initLit += (v.val1 + v.val2 + v.val3) / 3.0;
    }
    final initialGap = (initLit / 60.0 - initShadow / 60.0).abs();

    final enhanced = FilterRecipes.autoEnhance(fixture);
    double enhShadow = 0, enhLit = 0;
    for (int x = 20; x < 80; x++) {
      final v = enhanced.at<cv.Vec3b>(20, x);
      enhShadow += (v.val1 + v.val2 + v.val3) / 3.0;
    }
    for (int x = 120; x < 180; x++) {
      final v = enhanced.at<cv.Vec3b>(20, x);
      enhLit += (v.val1 + v.val2 + v.val3) / 3.0;
    }
    final enhGap = (enhLit / 60.0 - enhShadow / 60.0).abs();
    final gapReduction = (initialGap - enhGap) / initialGap;

    final textS = enhanced.at<cv.Vec3b>(50, 50);
    final textSBrightness = (textS.val1 + textS.val2 + textS.val3) / 3.0;
    final textL = enhanced.at<cv.Vec3b>(50, 150);
    final textLBrightness = (textL.val1 + textL.val2 + textL.val3) / 3.0;

    print('auto_enhance: initialGap=$initialGap, enhGap=$enhGap, reduction=${(gapReduction * 100).toStringAsFixed(1)}%');
    print('auto_enhance text: textS=$textSBrightness vs bgS=${enhShadow / 60.0}, textL=$textLBrightness vs bgL=${enhLit / 60.0}');

    expect(gapReduction, greaterThanOrEqualTo(0.50));
    expect(textSBrightness, lessThan(enhShadow / 60.0));
    expect(textLBrightness, lessThan(enhLit / 60.0));
    enhanced.dispose();
    fixture.dispose();
  });

  test('vivid_light has higher mean saturation than auto_enhance on a coloured fixture', () {
    final fixture = createTestFixture(withColor: true);
    final auto = FilterRecipes.autoEnhance(fixture);
    final vivid = FilterRecipes.vividLight(fixture);
    final autoHsv = cv.cvtColor(auto, cv.COLOR_BGR2HSV);
    final vividHsv = cv.cvtColor(vivid, cv.COLOR_BGR2HSV);
    final autoCh = cv.split(autoHsv), vividCh = cv.split(vividHsv);
    final autoSat = autoCh[1].data, vividSat = vividCh[1].data;

    double autoSum = 0, vividSum = 0;
    for (int i = 0; i < autoSat.length; i++) {
      autoSum += autoSat[i];
      vividSum += vividSat[i];
    }
    final autoMean = autoSum / autoSat.length, vividMean = vividSum / vividSat.length;
    print('vivid_light vs auto_enhance: autoMeanSat=$autoMean, vividMeanSat=$vividMean');
    expect(vividMean, greaterThan(autoMean));

    autoCh.dispose(); vividCh.dispose();
    autoHsv.dispose(); vividHsv.dispose();
    auto.dispose(); vivid.dispose(); fixture.dispose();
  });

  test('original returns identical pixels', () {
    final fixture = createTestFixture();
    final result = FilterRecipes.original(fixture);
    final origData = fixture.data, resData = result.data;
    expect(resData.length, equals(origData.length));
    int diffCount = 0;
    for (int i = 0; i < origData.length; i++) {
      if (origData[i] != resData[i]) diffCount++;
    }
    print('original: diffCount=$diffCount out of ${origData.length} bytes');
    expect(diffCount, equals(0));
    result.dispose();
    fixture.dispose();
  });

  test('Cache returns the same bytes and evicts beyond its limit', () {
    final cache = PreviewLruCache(capacity: 2);
    const k1 = PreviewCacheKey(path: 'p1', quadHash: 1, rotation: 0, filterId: 'original');
    const k2 = PreviewCacheKey(path: 'p2', quadHash: 2, rotation: 0, filterId: 'original');
    const k3 = PreviewCacheKey(path: 'p3', quadHash: 3, rotation: 0, filterId: 'original');
    final b1 = Uint8List.fromList([1, 2]), b2 = Uint8List.fromList([3, 4]), b3 = Uint8List.fromList([5, 6]);

    cache.put(k1, b1);
    cache.put(k2, b2);
    expect(cache.length, equals(2));
    expect(cache.get(k1), equals(b1));

    cache.put(k3, b3);
    expect(cache.length, equals(2));
    expect(cache.containsKey(k2), isFalse);
    expect(cache.containsKey(k1), isTrue);
    expect(cache.containsKey(k3), isTrue);
    print('cache: evicted k2, retained k1 and k3');
  });
}
