import 'package:flutter/foundation.dart';

@immutable
class ScanFilter {
  const ScanFilter({
    required this.id,
    required this.label,
  });

  final String id;
  final String label;

  static const original = ScanFilter(id: 'original', label: 'Original');
  static const autoEnhance = ScanFilter(id: 'auto_enhance', label: 'Auto Enhance');
  static const vividLight = ScanFilter(id: 'vivid_light', label: 'Vivid Light');
  static const grayscale = ScanFilter(id: 'grayscale', label: 'Grayscale');
  static const blackWhite = ScanFilter(id: 'black_white', label: 'Black & White');

  static const List<ScanFilter> all = [
    original,
    autoEnhance,
    vividLight,
    grayscale,
    blackWhite,
  ];

  static const List<ScanFilter> presets = all;

  static ScanFilter fromId(String id) {
    return all.firstWhere(
      (f) => f.id == id,
      orElse: () => vividLight,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScanFilter && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ScanFilter(id: $id, label: $label)';
}
