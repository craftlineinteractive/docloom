import 'dart:ui';
import '../data/edge_detector_constants.dart';
import 'quad.dart';

class LiveQuadStabilizer {
  LiveQuadStabilizer({
    this.nullHoldDuration = const Duration(milliseconds: kNullHoldDurationMs),
    this.smoothingFactor = kLiveSmoothingFactor,
    this.stabilityDistance = kStabilityDistanceThreshold,
  });

  final Duration nullHoldDuration;
  final double smoothingFactor;
  final double stabilityDistance;

  Quad? _lastQuad;
  DateTime? _lastDetectedTime;

  Quad? get currentQuad => _lastQuad;

  Quad? update(Quad? detected, [DateTime? now]) {
    final timestamp = now ?? DateTime.now();

    if (detected == null) {
      if (_lastQuad != null && _lastDetectedTime != null) {
        if (timestamp.difference(_lastDetectedTime!) <= nullHoldDuration) {
          return _lastQuad;
        }
      }
      _lastQuad = null;
      _lastDetectedTime = null;
      return null;
    }

    _lastDetectedTime = timestamp;
    if (_lastQuad == null) {
      _lastQuad = detected;
      return _lastQuad;
    }

    final prev = _lastQuad!;
    final dTl = (detected.tl - prev.tl).distance;
    final dTr = (detected.tr - prev.tr).distance;
    final dBr = (detected.br - prev.br).distance;
    final dBl = (detected.bl - prev.bl).distance;
    final maxDist = [dTl, dTr, dBr, dBl].reduce((a, b) => a > b ? a : b);

    if (maxDist > stabilityDistance) {
      _lastQuad = detected;
    } else {
      Offset smooth(Offset o, Offset n) =>
          Offset(o.dx + (n.dx - o.dx) * smoothingFactor, o.dy + (n.dy - o.dy) * smoothingFactor);
      _lastQuad = Quad(
        topLeft: smooth(prev.tl, detected.tl),
        topRight: smooth(prev.tr, detected.tr),
        bottomRight: smooth(prev.br, detected.br),
        bottomLeft: smooth(prev.bl, detected.bl),
      );
    }
    return _lastQuad;
  }

  void reset() {
    _lastQuad = null;
    _lastDetectedTime = null;
  }
}
