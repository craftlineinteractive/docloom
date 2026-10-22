import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'quad_geometry.dart';

@immutable
class Quad {
  const Quad({
    required this.topLeft,
    required this.topRight,
    required this.bottomRight,
    required this.bottomLeft,
  });

  factory Quad.fromUnordered(List<Offset> points) {
    final ordered = QuadGeometry.orderPoints(points);
    return Quad(
      topLeft: ordered[0],
      topRight: ordered[1],
      bottomRight: ordered[2],
      bottomLeft: ordered[3],
    );
  }

  factory Quad.unit() {
    return const Quad(
      topLeft: Offset(0, 0),
      topRight: Offset(1, 0),
      bottomRight: Offset(1, 1),
      bottomLeft: Offset(0, 1),
    );
  }

  factory Quad.defaultInset([double inset = 0.05]) {
    final start = inset;
    final end = 1.0 - inset;
    return Quad(
      topLeft: Offset(start, start),
      topRight: Offset(end, start),
      bottomRight: Offset(end, end),
      bottomLeft: Offset(start, end),
    );
  }

  factory Quad.fromJson(Map<String, dynamic> json) {
    Offset parse(dynamic val) {
      if (val is List && val.length >= 2) {
        return Offset((val[0] as num).toDouble(), (val[1] as num).toDouble());
      }
      if (val is Map<String, dynamic>) {
        return Offset((val['x'] as num).toDouble(), (val['y'] as num).toDouble());
      }
      throw ArgumentError.value(val, 'point', 'Invalid point format');
    }

    return Quad(
      topLeft: parse(json['tl'] ?? json['topLeft']),
      topRight: parse(json['tr'] ?? json['topRight']),
      bottomRight: parse(json['br'] ?? json['bottomRight']),
      bottomLeft: parse(json['bl'] ?? json['bottomLeft']),
    );
  }

  final Offset topLeft;
  final Offset topRight;
  final Offset bottomRight;
  final Offset bottomLeft;

  Offset get tl => topLeft;
  Offset get tr => topRight;
  Offset get br => bottomRight;
  Offset get bl => bottomLeft;

  List<Offset> get points => [topLeft, topRight, bottomRight, bottomLeft];

  bool get isValid => QuadGeometry.isValid(points);

  Quad toPixels(Size size) {
    return Quad(
      topLeft: Offset(topLeft.dx * size.width, topLeft.dy * size.height),
      topRight: Offset(topRight.dx * size.width, topRight.dy * size.height),
      bottomRight: Offset(bottomRight.dx * size.width, bottomRight.dy * size.height),
      bottomLeft: Offset(bottomLeft.dx * size.width, bottomLeft.dy * size.height),
    );
  }

  Quad rotated90() => QuadGeometry.rotate90(this);

  static String cropTypeOf(Map<String, dynamic> json) =>
      (json['type'] as String?) ?? 'quad';

  Map<String, dynamic> toJson({String type = 'quad'}) => {
        'type': type,
        'tl': [topLeft.dx, topLeft.dy],
        'tr': [topRight.dx, topRight.dy],
        'br': [bottomRight.dx, bottomRight.dy],
        'bl': [bottomLeft.dx, bottomLeft.dy],
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Quad &&
          runtimeType == other.runtimeType &&
          (topLeft - other.topLeft).distanceSquared < 1e-12 &&
          (topRight - other.topRight).distanceSquared < 1e-12 &&
          (bottomRight - other.bottomRight).distanceSquared < 1e-12 &&
          (bottomLeft - other.bottomLeft).distanceSquared < 1e-12;

  @override
  int get hashCode => Object.hash(
        topLeft.dx.toStringAsFixed(6),
        topLeft.dy.toStringAsFixed(6),
        topRight.dx.toStringAsFixed(6),
        topRight.dy.toStringAsFixed(6),
        bottomRight.dx.toStringAsFixed(6),
        bottomRight.dy.toStringAsFixed(6),
        bottomLeft.dx.toStringAsFixed(6),
        bottomLeft.dy.toStringAsFixed(6),
      );

  @override
  String toString() =>
      'Quad(tl: $topLeft, tr: $topRight, br: $bottomRight, bl: $bottomLeft)';
}
