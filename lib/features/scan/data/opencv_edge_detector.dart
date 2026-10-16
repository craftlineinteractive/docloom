// Read dartcv4/lib/src/imgcodecs/imgcodecs.dart for imread
import 'dart:isolate';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import '../domain/edge_detector.dart';
import '../domain/quad.dart';
import 'edge_detector_ops.dart';

final edgeDetectorProvider = Provider<EdgeDetector>((ref) {
  return OpencvEdgeDetector();
});

class OpencvEdgeDetector implements EdgeDetector {
  @override
  Future<Quad?> detectFromFile(String previewPath) async {
    try {
      return await Isolate.run(() {
        final src = cv.imread(previewPath, flags: cv.IMREAD_COLOR);
        if (src.isEmpty) return null;
        try {
          return EdgeDetectorOps.detectFromMat(src);
        } finally {
          src.dispose();
        }
      });
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Quad?> detectFromGray(Uint8List gray, int width, int height) async {
    try {
      return await Isolate.run(() {
        final mat = cv.Mat.fromVec(
          cv.VecU8.fromList(gray),
          rows: height,
          cols: width,
          type: cv.MatType.CV_8UC1,
        );
        try {
          final bgr = cv.cvtColor(mat, cv.COLOR_GRAY2BGR);
          try {
            return EdgeDetectorOps.detectFromMat(bgr);
          } finally {
            bgr.dispose();
          }
        } finally {
          mat.dispose();
        }
      });
    } catch (_) {
      return null;
    }
  }
}
