import 'package:flutter/foundation.dart';

@immutable
class ScanPage {
  const ScanPage({
    required this.id,
    required this.documentId,
    required this.position,
    required this.originalPath,
    this.editedPath,
    this.filterId = 'original',
    this.rotation = 0,
    this.cropJson,
    required this.createdAt,
  });

  final String id;
  final String documentId;
  final int position;
  final String originalPath;
  final String? editedPath;
  final String filterId;
  final int rotation;
  final String? cropJson;
  final DateTime createdAt;

  String get displayPath => editedPath ?? originalPath;

  ScanPage copyWith({
    String? id,
    String? documentId,
    int? position,
    String? originalPath,
    String? editedPath,
    String? filterId,
    int? rotation,
    String? cropJson,
    DateTime? createdAt,
  }) {
    return ScanPage(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      position: position ?? this.position,
      originalPath: originalPath ?? this.originalPath,
      editedPath: editedPath ?? this.editedPath,
      filterId: filterId ?? this.filterId,
      rotation: rotation ?? this.rotation,
      cropJson: cropJson ?? this.cropJson,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  ScanPage withEditedPath(String? editedPath) => ScanPage(
        id: id,
        documentId: documentId,
        position: position,
        originalPath: originalPath,
        editedPath: editedPath,
        filterId: filterId,
        rotation: rotation,
        cropJson: cropJson,
        createdAt: createdAt,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'document_id': documentId,
        'position': position,
        'original_path': originalPath,
        'edited_path': editedPath,
        'filter_id': filterId,
        'rotation': rotation,
        'crop_json': cropJson,
        'created_at': createdAt.millisecondsSinceEpoch,
      };

  factory ScanPage.fromMap(Map<String, Object?> map) {
    return ScanPage(
      id: map['id'] as String,
      documentId: map['document_id'] as String,
      position: map['position'] as int,
      originalPath: map['original_path'] as String,
      editedPath: map['edited_path'] as String?,
      filterId: (map['filter_id'] as String?) ?? 'original',
      rotation: (map['rotation'] as int?) ?? 0,
      cropJson: map['crop_json'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['created_at'] as int,
        isUtc: true,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScanPage &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          documentId == other.documentId &&
          position == other.position &&
          originalPath == other.originalPath &&
          editedPath == other.editedPath &&
          filterId == other.filterId &&
          rotation == other.rotation &&
          cropJson == other.cropJson &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(
        id,
        documentId,
        position,
        originalPath,
        editedPath,
        filterId,
        rotation,
        cropJson,
        createdAt,
      );
}
