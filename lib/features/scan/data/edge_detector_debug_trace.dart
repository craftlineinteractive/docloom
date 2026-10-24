import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import '../domain/quad.dart';
import 'edge_detector_evaluator.dart';

@immutable
class EdgeDetectionDebugTrace {
  const EdgeDetectionDebugTrace({
    required this.grayBytes,
    required this.blurredBytes,
    required this.edgesBytes,
    required this.maskBytes,
    required this.candidates,
    required this.finalQuad,
    this.sourceBytes,
  });

  final Uint8List grayBytes;
  final Uint8List blurredBytes;
  final Uint8List edgesBytes;
  final Uint8List maskBytes;
  final List<CandidateQuad> candidates;
  final Quad? finalQuad;
  final Uint8List? sourceBytes;

  static Uint8List matToPng(cv.Mat mat) {
    final (ok, bytes) = cv.imencode('.png', mat);
    if (!ok) return Uint8List(0);
    return bytes;
  }

  Future<void> writeToDirectory(String dirPath) async {
    final dir = Directory(dirPath);
    if (!dir.existsSync()) dir.createSync(recursive: true);

    await File('${dir.path}/01_gray.png').writeAsBytes(grayBytes);
    await File('${dir.path}/02_blurred.png').writeAsBytes(blurredBytes);
    await File('${dir.path}/03_edges.png').writeAsBytes(edgesBytes);
    await File('${dir.path}/04_mask.png').writeAsBytes(maskBytes);
    if (sourceBytes != null) {
      await File('${dir.path}/00_source.png').writeAsBytes(sourceBytes!);
    }

    final sb = StringBuffer('Candidate Quads (count: ${candidates.length}):\n\n');
    for (var i = 0; i < candidates.length; i++) {
      final c = candidates[i];
      sb.writeln('Candidate #$i:');
      sb.writeln('  Quad: ${c.quad}');
      sb.writeln('  Score: ${c.score.toStringAsFixed(4)}');
      sb.writeln('  AreaRatio: ${(c.areaRatio * 100).toStringAsFixed(1)}%');
      sb.writeln('  RectScore: ${c.rectScore.toStringAsFixed(3)}');
      sb.writeln('  AngleScore: ${c.angleScore.toStringAsFixed(3)}');
      sb.writeln('  EdgeSupport: ${c.edgeSupport.toStringAsFixed(3)}');
      sb.writeln('  Accepted: ${c.isAccepted}');
      if (c.rejectionReason != null) {
        sb.writeln('  RejectionReason: ${c.rejectionReason}');
      }
      sb.writeln();
    }
    sb.writeln('Final Quad: $finalQuad');
    await File('${dir.path}/05_candidates.txt').writeAsString(sb.toString());
  }
}
