import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'package:docloom/features/scan/data/signature_processor.dart';

void main() {
  test('SignatureProcessor processes signature to transparent PNG and trims margin', () async {
    final tempDir = Directory.systemTemp.createTempSync();
    final srcPath = '${tempDir.path}/raw_signature.jpg';
    final dstPath = '${tempDir.path}/sig_out.png';

    // Create 400x300 image: white background with black box in center (150..250, 100..200)
    final src = cv.Mat.fromScalar(300, 400, cv.MatType.CV_8UC3, cv.Scalar(255, 255, 255, 0));
    final inkRoi = src.rowRange(100, 200).colRange(150, 250);
    final blackMat = cv.Mat.fromScalar(100, 100, cv.MatType.CV_8UC3, cv.Scalar(0, 0, 0, 0));
    blackMat.copyTo(inkRoi);
    inkRoi.dispose();
    blackMat.dispose();

    cv.imwrite(srcPath, src);
    src.dispose();

    final resultPath = await SignatureProcessor.process(srcPath: srcPath, dstPath: dstPath);
    expect(File(resultPath).existsSync(), isTrue);

    final result = cv.imread(resultPath, flags: cv.IMREAD_UNCHANGED);
    expect(result.channels, equals(4));

    // Bounding box was 100x100 + padding 16 on each side = 132x132
    expect(result.width, equals(100 + SignatureProcessor.padding * 2));
    expect(result.height, equals(100 + SignatureProcessor.padding * 2));

    // Check pixel at top-left of trimmed image (should be padding, so transparent alpha == 0)
    final bytes = result.data;
    final w = result.width;
    expect(bytes[3], equals(0)); // alpha at (0, 0)

    // Check pixel in center of ink (width ~/ 2, height ~/ 2)
    final centerIdx = ((result.height ~/ 2) * w + (result.width ~/ 2)) * 4;
    expect(bytes[centerIdx], equals(0)); // B
    expect(bytes[centerIdx + 1], equals(0)); // G
    expect(bytes[centerIdx + 2], equals(0)); // R
    expect(bytes[centerIdx + 3], greaterThan(200)); // Alpha > 200

    result.dispose();
    tempDir.deleteSync(recursive: true);
  });

  test('SignatureProcessor scales down image exceeding maxWidth 1000', () async {
    final tempDir = Directory.systemTemp.createTempSync();
    final srcPath = '${tempDir.path}/wide_signature.jpg';
    final dstPath = '${tempDir.path}/wide_out.png';

    // Create 1500x400 image with ink
    final src = cv.Mat.fromScalar(400, 1500, cv.MatType.CV_8UC3, cv.Scalar(255, 255, 255, 0));
    final inkRoi = src.rowRange(100, 300).colRange(50, 1450);
    final blackMat = cv.Mat.fromScalar(200, 1400, cv.MatType.CV_8UC3, cv.Scalar(0, 0, 0, 0));
    blackMat.copyTo(inkRoi);
    inkRoi.dispose();
    blackMat.dispose();
    cv.imwrite(srcPath, src);
    src.dispose();

    final resultPath = await SignatureProcessor.process(srcPath: srcPath, dstPath: dstPath);
    final result = cv.imread(resultPath, flags: cv.IMREAD_UNCHANGED);
    expect(result.width, equals(SignatureProcessor.maxWidth));
    expect(result.channels, equals(4));
    result.dispose();
    tempDir.deleteSync(recursive: true);
  });
}
