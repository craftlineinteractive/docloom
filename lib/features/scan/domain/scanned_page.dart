import 'package:flutter/foundation.dart';

@immutable
class ScannedPage {
  const ScannedPage({
    required this.originalPath,
    this.editedPath,
    this.filterId = 'original',
    this.rotation = 0,
    this.cropJson,
  });

  final String originalPath;
  final String? editedPath;
  final String filterId;
  final int rotation;
  final String? cropJson;

  ScannedPage copyWith({
    String? originalPath,
    String? editedPath,
    String? filterId,
    int? rotation,
    String? cropJson,
  }) {
    return ScannedPage(
      originalPath: originalPath ?? this.originalPath,
      editedPath: editedPath ?? this.editedPath,
      filterId: filterId ?? this.filterId,
      rotation: rotation ?? this.rotation,
      cropJson: cropJson ?? this.cropJson,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScannedPage &&
          runtimeType == other.runtimeType &&
          originalPath == other.originalPath &&
          editedPath == other.editedPath &&
          filterId == other.filterId &&
          rotation == other.rotation &&
          cropJson == other.cropJson;

  @override
  int get hashCode => Object.hash(
        originalPath,
        editedPath,
        filterId,
        rotation,
        cropJson,
      );

  @override
  String toString() =>
      'ScannedPage(originalPath: $originalPath, editedPath: $editedPath, filterId: $filterId, rotation: $rotation, cropJson: $cropJson)';
}
