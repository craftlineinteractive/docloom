import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'package:docloom/features/scan/data/opencv_card_ops.dart';
import 'package:docloom/features/scan/domain/id_card_layout.dart';

void main() {
  test('OpencvCardOps composes single card onto A4 page', () {
    final tempDir = Directory.systemTemp.createTempSync();
    final frontPath = '${tempDir.path}/front.jpg';
    final outPath = '${tempDir.path}/a4_single.jpg';

    // Create 300x200 card image
    final card = cv.Mat.fromScalar(200, 300, cv.MatType.CV_8UC3, cv.Scalar(0, 0, 255, 0)); // Red
    cv.imwrite(frontPath, card);
    card.dispose();

    OpencvCardOps.composeCardPage(
      frontPath: frontPath,
      backPath: null,
      dstPath: outPath,
      quality: 85,
    );

    final result = cv.imread(outPath, flags: cv.IMREAD_COLOR);
    expect(result.width, equals(IdCardLayout.a4Width));
    expect(result.height, equals(IdCardLayout.a4Height));
    result.dispose();
    tempDir.deleteSync(recursive: true);
  });

  test('OpencvCardOps composes both sides onto A4 page', () {
    final tempDir = Directory.systemTemp.createTempSync();
    final frontPath = '${tempDir.path}/front.jpg';
    final backPath = '${tempDir.path}/back.jpg';
    final outPath = '${tempDir.path}/a4_both.jpg';

    final front = cv.Mat.fromScalar(200, 300, cv.MatType.CV_8UC3, cv.Scalar(0, 0, 255, 0));
    final back = cv.Mat.fromScalar(200, 300, cv.MatType.CV_8UC3, cv.Scalar(0, 255, 0, 0));
    cv.imwrite(frontPath, front);
    cv.imwrite(backPath, back);
    front.dispose();
    back.dispose();

    OpencvCardOps.composeCardPage(
      frontPath: frontPath,
      backPath: backPath,
      dstPath: outPath,
      quality: 85,
    );

    final result = cv.imread(outPath, flags: cv.IMREAD_COLOR);
    expect(result.width, equals(IdCardLayout.a4Width));
    expect(result.height, equals(IdCardLayout.a4Height));
    result.dispose();
    tempDir.deleteSync(recursive: true);
  });
}
