import 'dart:isolate';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import '../domain/edge_detector.dart';
import '../domain/quad.dart';
import 'edge_detector_debug_trace.dart';
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
  Future<(Quad?, EdgeDetectionDebugTrace?)> detectFromFileWithTrace(String path) async {
    try {
      return await Isolate.run(() {
        final src = cv.imread(path, flags: cv.IMREAD_COLOR);
        if (src.isEmpty) return (null, null);
        try {
          return EdgeDetectorOps.detectWithTrace(src, recordTrace: true);
        } finally {
          src.dispose();
        }
      });
    } catch (_) {
      return (null, null);
    }
  }

  @override
  Future<Quad?> detectFromGray(
    Uint8List gray,
    int width,
    int height, {
    int sensorOrientation = 0,
    int bytesPerRow = 0,
  }) async {
    try {
      return await Isolate.run(() {
        Uint8List compact = gray;
        if (bytesPerRow > 0 && bytesPerRow != width) {
          compact = Uint8List(width * height);
          for (var r = 0; r < height; r++) {
            compact.setRange(r * width, (r + 1) * width, gray, r * bytesPerRow);
          }
        }
        cv.Mat mat = cv.Mat.fromVec(
          cv.VecU8.fromList(compact),
          rows: height,
          cols: width,
          type: cv.MatType.CV_8UC1,
        );
        try {
          if (sensorOrientation == 90) {
            final rot = cv.rotate(mat, cv.ROTATE_90_CLOCKWISE);
            mat.dispose(); mat = rot;
          } else if (sensorOrientation == 180) {
            final rot = cv.rotate(mat, cv.ROTATE_180);
            mat.dispose(); mat = rot;
          } else if (sensorOrientation == 270) {
            final rot = cv.rotate(mat, cv.ROTATE_90_COUNTERCLOCKWISE);
            mat.dispose(); mat = rot;
          }
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
