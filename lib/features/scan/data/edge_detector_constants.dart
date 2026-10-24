// Named constants for edge detection pipeline
const int kDetectMaxSide = 500;
const int kBlurKernelSize = 5;
const int kMorphKernelSize = 5;
const int kDilateIterations = 2;
const double kCannySigma = 0.33;

const double kSensitiveCannyLow = 20.0;
const double kSensitiveCannyHigh = 60.0;

const List<double> kEpsilonRatios = [
  0.02, 0.025, 0.03, 0.035, 0.04, 0.05, 0.06, 0.07, 0.08,
];
const List<int> kAdaptiveBlockSizes = [25, 35, 45];
const double kAdaptiveC = 10.0;
const List<double> kLuminanceThresholds = [170.0, 225.0];

const double kMinAreaRatio = 0.20;
const double kMaxAreaRatio = 0.95;
const double kBorderMargin = 0.015;
const double kBorderQuadMinRect = 0.88;
const double kBorderQuadMinAngle = 0.85;
const double kMinScoreThreshold = 0.01;

const int kNullHoldDurationMs = 400;
const double kLiveSmoothingFactor = 0.3;
const double kStabilityDistanceThreshold = 0.08;
