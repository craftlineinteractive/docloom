import 'package:flutter/foundation.dart';
import 'photo_size_presets.dart';

enum PhotoUnit {
  inches,
  mm,
  cm,
  px;

  String get label => switch (this) {
        PhotoUnit.inches => 'in',
        PhotoUnit.mm => 'mm',
        PhotoUnit.cm => 'cm',
        PhotoUnit.px => 'px',
      };
}

@immutable
class PixelSize {
  const PixelSize({required this.width, required this.height});
  final int width;
  final int height;

  double get aspectRatio => width / height;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PixelSize &&
          runtimeType == other.runtimeType &&
          width == other.width &&
          height == other.height;

  @override
  int get hashCode => Object.hash(width, height);

  @override
  String toString() => '${width}x$height';
}

@immutable
class PhotoSize {
  // ignore: prefer_initializing_formals
  const PhotoSize({
    required this.id,
    required this.width,
    required this.height,
    required this.unit,
    required this.dpi,
    String? title,
    String? subtitle,
  })  : _rawTitle = title,
        _rawSubtitle = subtitle;

  final String id;
  final double width;
  final double height;
  final PhotoUnit unit;
  final int dpi;
  final String? _rawTitle;
  final String? _rawSubtitle;

  String get title => _rawTitle ?? _formatTitle(width, height, unit);
  String get subtitle => _rawSubtitle ?? _formatSubtitle(unit, dpi);

  PixelSize get pixelSize => calculatePixels(
        width: width,
        height: height,
        unit: unit,
        dpi: dpi,
      );

  static PixelSize calculatePixels({
    required double width,
    required double height,
    required PhotoUnit unit,
    required int dpi,
  }) =>
      switch (unit) {
        PhotoUnit.inches => PixelSize(
            width: (width * dpi).round(),
            height: (height * dpi).round(),
          ),
        PhotoUnit.mm => PixelSize(
            width: ((width / 25.4) * dpi).round(),
            height: ((height / 25.4) * dpi).round(),
          ),
        PhotoUnit.cm => PixelSize(
            width: ((width / 2.54) * dpi).round(),
            height: ((height / 2.54) * dpi).round(),
          ),
        PhotoUnit.px => PixelSize(
            width: width.round(),
            height: height.round(),
          ),
      };

  static String _formatTitle(double w, double h, PhotoUnit unit) {
    String clean(double n) =>
        n.truncateToDouble() == n ? n.toInt().toString() : n.toString();
    final u = switch (unit) {
      PhotoUnit.inches => 'INCHES',
      PhotoUnit.mm => 'MM',
      PhotoUnit.cm => 'CM',
      PhotoUnit.px => 'PX',
    };
    return '${clean(w)} × ${clean(h)} $u';
  }

  static String _formatSubtitle(PhotoUnit unit, int dpi) =>
      unit == PhotoUnit.px ? 'PIXEL' : 'DPI $dpi';

  static List<PhotoSize> get defaultPresets => PhotoSizePresets.defaults;

  Map<String, dynamic> toJson() => {
        'id': id,
        'width': width,
        'height': height,
        'unit': unit.name,
        'dpi': dpi,
        'title': title,
        'subtitle': subtitle,
      };

  factory PhotoSize.fromJson(Map<String, dynamic> json) => PhotoSize(
        id: json['id'] as String,
        width: (json['width'] as num).toDouble(),
        height: (json['height'] as num).toDouble(),
        unit: PhotoUnit.values.byName(json['unit'] as String),
        dpi: (json['dpi'] as num).toInt(),
        title: json['title'] as String?,
        subtitle: json['subtitle'] as String?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhotoSize &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          width == other.width &&
          height == other.height &&
          unit == other.unit &&
          dpi == other.dpi;

  @override
  int get hashCode => Object.hash(id, width, height, unit, dpi);
}
