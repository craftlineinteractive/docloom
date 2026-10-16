import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'package:docloom/features/scan/data/edge_detector_ops.dart';
import 'package:docloom/features/scan/domain/quad.dart';

double computeIoU(Quad q, Quad g) {
  final v1 = cv.VecPoint.fromList(q.points.map((p) => cv.Point((p.dx * 1000).round(), (p.dy * 1000).round())).toList());
  final v2 = cv.VecPoint.fromList(g.points.map((p) => cv.Point((p.dx * 1000).round(), (p.dy * 1000).round())).toList());
  try {
    final (interArea, p12) = cv.intersectConvexConvex(v1, v2);
    p12.dispose();
    final a1 = cv.contourArea(v1), a2 = cv.contourArea(v2);
    final unionArea = a1 + a2 - interArea;
    return unionArea > 0 ? (interArea / unionArea).clamp(0.0, 1.0) : 0.0;
  } finally {
    v1.dispose();
    v2.dispose();
  }
}

double computeCornerError(Quad q, Quad g) {
  final diag = math.sqrt(2.0);
  var sum = 0.0;
  for (var i = 0; i < 4; i++) {
    final d = (q.points[i] - g.points[i]).distance;
    sum += d;
  }
  return (sum / 4.0) / diag;
}

void main() {
  test('Phase 4H Evaluation: IoU against ground truth and corner error', () {
    final dir = Directory('test/fixtures/documents');
    final files = dir.listSync().whereType<File>().where((f) => f.path.endsWith('.jpg')).toList()
      ..sort((a, b) => a.path.compareTo(b.path));

    expect(files.length, greaterThanOrEqualTo(15), reason: 'Must have at least 15 images');

    print('\n========================================================================================');
    print(r'| File Name                  | IoU       | Corner Error | Detection Result               |');
    print('----------------------------------------------------------------------------------------');

    var totalIoU = 0.0;
    var worstIoU = 1.0;
    String worstImage = '';
    final iouList = <double>[];

    for (final file in files) {
      final name = file.uri.pathSegments.last;
      final jsonFile = File(file.path.replaceAll('.jpg', '.json'));
      expect(jsonFile.existsSync(), isTrue, reason: 'Ground truth missing for $name');

      final gtJson = jsonDecode(jsonFile.readAsStringSync()) as Map<String, dynamic>;
      final gtCorners = (gtJson['corners'] as List).map((p) => Offset((p[0] as num).toDouble(), (p[1] as num).toDouble())).toList();
      final gtQuad = Quad.fromUnordered(gtCorners);

      final src = cv.imread(file.path, flags: cv.IMREAD_COLOR);
      final detected = EdgeDetectorOps.detectFromMat(src);
      src.dispose();

      if (detected != null) {
        final iou = computeIoU(detected, gtQuad);
        final err = computeCornerError(detected, gtQuad);
        iouList.add(iou);
        totalIoU += iou;
        if (iou < worstIoU) {
          worstIoU = iou;
          worstImage = name;
        }
        print('| ${name.padRight(26)} | ${iou.toStringAsFixed(4).padRight(9)} | ${(err * 100).toStringAsFixed(2).padLeft(10)}% | OK                             |');
      } else {
        iouList.add(0.0);
        worstIoU = 0.0;
        worstImage = name;
        print('| ${name.padRight(26)} | 0.0000    |    100.00%   | NULL                           |');
      }
    }

    final meanIoU = totalIoU / files.length;
    print('========================================================================================');
    print('Mean IoU: ${meanIoU.toStringAsFixed(4)}');
    print('Worst Image: $worstImage (IoU: ${worstIoU.toStringAsFixed(4)})\n');

    expect(meanIoU, greaterThanOrEqualTo(0.90), reason: 'Mean IoU must be >= 0.90');
    for (var i = 0; i < iouList.length; i++) {
      expect(iouList[i], greaterThanOrEqualTo(0.70), reason: 'Fixture ${files[i].path} fell below 0.70 IoU');
    }
  });
}
