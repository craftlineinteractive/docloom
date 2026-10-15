// Read dartcv4/lib/src/imgproc/imgproc.dart and dartcv4/lib/src/core/core.dart
import 'package:opencv_dart/opencv_dart.dart' as cv;

const int kGrayscaleCodeToGray = cv.COLOR_BGR2GRAY;
const int kGrayscaleCodeToBgr = cv.COLOR_GRAY2BGR;

const int kBwMedianBlurKsize = 3;
const double kBwAdaptiveThreshMaxValue = 255.0;
const int kBwAdaptiveMethod = cv.ADAPTIVE_THRESH_GAUSSIAN_C;
const int kBwThreshType = cv.THRESH_BINARY;
const int kBwAdaptiveBlockSize = 25;
const double kBwAdaptiveC = 10.0;

const int kAutoEnhanceDilateShape = cv.MORPH_RECT;
const int kAutoEnhanceDilateKsize = 11;
const int kAutoEnhanceBlurKsize = 51;
const double kAutoEnhanceBlurSigma = 0.0;
const double kAutoEnhanceDivideScale = 255.0;
const double kAutoEnhanceNormalizeMin = 0.0;
const double kAutoEnhanceNormalizeMax = 255.0;
const int kAutoEnhanceNormalizeType = cv.NORM_MINMAX;

const int kVividColorCodeToHsv = cv.COLOR_BGR2HSV;
const int kVividColorCodeToBgr = cv.COLOR_HSV2BGR;
const int kChannelHue = 0;
const int kChannelSat = 1;
const int kChannelVal = 2;
const double kVividSaturationBoostAlpha = 1.30;
const double kVividSaturationBoostBeta = 0.0;
const double kVividContrastLiftAlpha = 1.05;
const double kVividContrastLiftBeta = 2.0;

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
    final gray = cv.cvtColor(src, kGrayscaleCodeToGray);
    final bgr = cv.cvtColor(gray, kGrayscaleCodeToBgr);
    gray.dispose();
    return bgr;
  }

  static cv.Mat blackWhite(cv.Mat src) {
    final gray = cv.cvtColor(src, kGrayscaleCodeToGray);
    final blurred = cv.medianBlur(gray, kBwMedianBlurKsize);
    gray.dispose();
    final thresh = cv.adaptiveThreshold(
      blurred,
      kBwAdaptiveThreshMaxValue,
      kBwAdaptiveMethod,
      kBwThreshType,
      kBwAdaptiveBlockSize,
      kBwAdaptiveC,
    );
    blurred.dispose();
    final bgr = cv.cvtColor(thresh, kGrayscaleCodeToBgr);
    thresh.dispose();
    return bgr;
  }

  static cv.Mat autoEnhance(cv.Mat src) {
    final channels = cv.split(src);
    final kSize = (kAutoEnhanceDilateKsize, kAutoEnhanceDilateKsize);
    final kernel = cv.getStructuringElement(kAutoEnhanceDilateShape, kSize);
    final processedList = <cv.Mat>[];
    try {
      for (int i = 0; i < channels.length; i++) {
        final ch = channels[i];
        final dilated = cv.dilate(ch, kernel);
        final bg = cv.gaussianBlur(
          dilated,
          (kAutoEnhanceBlurKsize, kAutoEnhanceBlurKsize),
          kAutoEnhanceBlurSigma,
        );
        dilated.dispose();
        final div = cv.divide(ch, bg, scale: kAutoEnhanceDivideScale);
        bg.dispose();
        final norm = cv.Mat.empty();
        cv.normalize(
          div,
          norm,
          alpha: kAutoEnhanceNormalizeMin,
          beta: kAutoEnhanceNormalizeMax,
          normType: kAutoEnhanceNormalizeType,
        );
        div.dispose();
        processedList.add(norm);
      }
      final mv = cv.VecMat.fromList(processedList);
      try {
        return cv.merge(mv);
      } finally {
        mv.dispose();
      }
    } finally {
      kernel.dispose();
      channels.dispose();
      for (final m in processedList) {
        m.dispose();
      }
    }
  }

  static cv.Mat vividLight(cv.Mat src) {
    final enhanced = autoEnhance(src);
    final hsv = cv.cvtColor(enhanced, kVividColorCodeToHsv);
    enhanced.dispose();

    final channels = cv.split(hsv);
    hsv.dispose();
    final h = channels[kChannelHue];
    final s = channels[kChannelSat];
    final v = channels[kChannelVal];

    final boostedS = cv.convertScaleAbs(s,
        alpha: kVividSaturationBoostAlpha, beta: kVividSaturationBoostBeta);
    final liftedV = cv.convertScaleAbs(v,
        alpha: kVividContrastLiftAlpha, beta: kVividContrastLiftBeta);

    final mergedVec = cv.VecMat.fromList([h, boostedS, liftedV]);
    final boostedHsv = cv.merge(mergedVec);
    mergedVec.dispose();
    boostedS.dispose();
    liftedV.dispose();
    channels.dispose();

    final result = cv.cvtColor(boostedHsv, kVividColorCodeToBgr);
    boostedHsv.dispose();
    return result;
  }
}
