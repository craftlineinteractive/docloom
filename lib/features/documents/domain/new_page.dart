import 'package:flutter/foundation.dart';

@immutable
class NewPage {
  const NewPage({
    required this.id,
    required this.originalPath,
    this.editedPath,
    this.filterId = 'original',
    this.rotation = 0,
    this.cropJson,
  });

  final String id;
  final String originalPath;
  final String? editedPath;
  final String filterId;
  final int rotation;
  final String? cropJson;

  NewPage copyWith({
    String? id,
    String? originalPath,
    String? editedPath,
    String? filterId,
    int? rotation,
    String? cropJson,
  }) {
    return NewPage(
      id: id ?? this.id,
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
      other is NewPage &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          originalPath == other.originalPath &&
          editedPath == other.editedPath &&
          filterId == other.filterId &&
          rotation == other.rotation &&
          cropJson == other.cropJson;

  @override
  int get hashCode => Object.hash(
        id,
        originalPath,
        editedPath,
        filterId,
        rotation,
        cropJson,
      );
}
