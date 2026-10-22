import 'dart:io';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import '../domain/id_card_layout.dart';

class OpencvCardOps {
  const OpencvCardOps._();

  static String composeCardPage({
    required String frontPath,
    String? backPath,
    required String dstPath,
    required int quality,
  }) {
    final parent = File(dstPath).parent;
    if (!parent.existsSync()) parent.createSync(recursive: true);

    final a4 = cv.Mat.fromScalar(
      IdCardLayout.a4Height,
      IdCardLayout.a4Width,
      cv.MatType.CV_8UC3,
      cv.Scalar(255, 255, 255, 0),
    );

    try {
      _pasteCard(a4, frontPath, IdCardLayout.frontTop);
      if (backPath != null) {
        _pasteCard(a4, backPath, IdCardLayout.backTop);
      }

      final params = cv.VecI32.fromList([cv.IMWRITE_JPEG_QUALITY, quality]);
      try {
        final ok = cv.imwrite(dstPath, a4, params: params);
        if (!ok) throw StateError('Failed to write composed card page to $dstPath');
      } finally {
        params.dispose();
      }
      return dstPath;
    } finally {
      a4.dispose();
    }
  }

  static void _pasteCard(cv.Mat a4, String path, int top) {
    final card = cv.imread(path, flags: cv.IMREAD_COLOR);
    if (card.isEmpty) {
      card.dispose();
      throw ArgumentError('Failed to read card image at $path');
    }
    try {
      final resized = cv.resize(
        card,
        (IdCardLayout.cardWidth, IdCardLayout.cardHeight),
        interpolation: cv.INTER_AREA,
      );
      try {
        final roi = a4
            .rowRange(top, top + IdCardLayout.cardHeight)
            .colRange(IdCardLayout.leftMargin, IdCardLayout.leftMargin + IdCardLayout.cardWidth);
        resized.copyTo(roi);
        roi.dispose();
      } finally {
        resized.dispose();
      }
    } finally {
      card.dispose();
    }
  }
}
