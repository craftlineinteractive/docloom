import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'filter_ops_helper.dart';

const double kClaheClipLimit = 2.0;
const (int, int) kClaheTileGridSize = (8, 8);
const double kUnsharpAmount = 0.6;
const double kVividChromaMultiplier = 1.18;
const double kVividGamma = 1.0;
const int kBwAdaptiveBlockSize = 25;
const double kBwAdaptiveC = 10.0;
const int kBwMedianBlurKsize = 3;

abstract final class FilterRecipes {
  static cv.Mat apply(cv.Mat src, String filterId) {
    return switch (filterId) {
      'original' => original(src),
      'grayscale' => grayscale(src),
      'black_white' => blackWhite(src),
      'auto_enhance' => autoEnhance(src),
      'vivid_light' => vividLight(src),
      _ => throw UnsupportedError('Unsupported filterId: $filterId'),
    };
  }

  static cv.Mat original(cv.Mat src) => src.clone();

  static cv.Mat grayscale(cv.Mat src) {
    final flattened = FilterOpsHelper.flattenShadows(src);
    final gray = cv.cvtColor(flattened, cv.COLOR_BGR2GRAY);
    flattened.dispose();
    final sharpened = FilterOpsHelper.unsharpMask(gray, amount: kUnsharpAmount);
    gray.dispose();
    final bgr = cv.cvtColor(sharpened, cv.COLOR_GRAY2BGR);
    sharpened.dispose();
    return bgr;
  }

  static cv.Mat blackWhite(cv.Mat src) {
    final flattened = FilterOpsHelper.flattenShadows(src);
    final gray = cv.cvtColor(flattened, cv.COLOR_BGR2GRAY);
    flattened.dispose();
    final thresh = cv.adaptiveThreshold(
      gray,
      255.0,
      cv.ADAPTIVE_THRESH_GAUSSIAN_C,
      cv.THRESH_BINARY,
      kBwAdaptiveBlockSize,
      kBwAdaptiveC,
    );
    gray.dispose();
    final despeckled = cv.medianBlur(thresh, kBwMedianBlurKsize);
    thresh.dispose();
    final bgr = cv.cvtColor(despeckled, cv.COLOR_GRAY2BGR);
    despeckled.dispose();
    return bgr;
  }

  static cv.Mat autoEnhance(cv.Mat src) {
    final flattened = FilterOpsHelper.flattenShadows(src);
    final stretched = FilterOpsHelper.levelsStretch(flattened);
    flattened.dispose();
    final clahe = FilterOpsHelper.applyClahe(
      stretched,
      clipLimit: kClaheClipLimit,
      tileGridSize: kClaheTileGridSize,
    );
    stretched.dispose();
    final sharpened = FilterOpsHelper.unsharpMask(clahe, amount: kUnsharpAmount);
    clahe.dispose();
    return sharpened;
  }

  static cv.Mat vividLight(cv.Mat src) {
    final enhanced = autoEnhance(src);
    final boosted = FilterOpsHelper.boostChroma(
      enhanced,
      chromaMultiplier: kVividChromaMultiplier,
      gamma: kVividGamma,
    );
    enhanced.dispose();
    return boosted;
  }
}
