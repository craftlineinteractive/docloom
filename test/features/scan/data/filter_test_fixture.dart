import 'package:opencv_dart/opencv_dart.dart' as cv;

cv.Mat createTestFixture({bool withColor = false}) {
  const width = 200, height = 200;
  final fixture = cv.Mat.zeros(height, width, cv.MatType.CV_8UC3);

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final int val = x < 100 ? (100 + (x / 100) * 40).round() : 240;
      fixture.set<cv.Vec3b>(y, x, cv.Vec3b(val, val, val));
    }
  }
  for (int y = 48; y <= 52; y++) {
    for (int x = 20; x < 180; x++) {
      fixture.set<cv.Vec3b>(y, x, cv.Vec3b(15, 15, 15));
    }
  }
  for (int y = 98; y <= 102; y++) {
    for (int x = 20; x < 180; x++) {
      fixture.set<cv.Vec3b>(y, x, cv.Vec3b(15, 15, 15));
    }
  }
  if (withColor) {
    for (int y = 140; y < 170; y++) {
      for (int x = 40; x < 160; x++) {
        fixture.set<cv.Vec3b>(y, x, cv.Vec3b(220, 50, 30));
      }
    }
  }
  return fixture;
}
