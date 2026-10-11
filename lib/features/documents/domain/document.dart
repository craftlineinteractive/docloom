import 'package:flutter/foundation.dart';

@immutable
class Document {
  const Document({
    required this.id,
    this.folderId,
    required this.name,
    this.isFavorite = false,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String? folderId;
  final String name;
  final bool isFavorite;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Document copyWith({
    String? id,
    String? folderId,
    String? name,
    bool? isFavorite,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Document(
      id: id ?? this.id,
      folderId: folderId ?? this.folderId,
      name: name ?? this.name,
      isFavorite: isFavorite ?? this.isFavorite,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Document withDeletedAt(DateTime? deletedAt) => Document(
        id: id,
        folderId: folderId,
        name: name,
        isFavorite: isFavorite,
        note: note,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );

  Document withFolderId(String? folderId) => Document(
        id: id,
        folderId: folderId,
        name: name,
        isFavorite: isFavorite,
        note: note,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );

  Document withNote(String? note) => Document(
        id: id,
        folderId: folderId,
        name: name,
        isFavorite: isFavorite,
        note: note,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'folder_id': folderId,
        'name': name,
        'is_favorite': isFavorite ? 1 : 0,
        'note': note,
        'created_at': createdAt.millisecondsSinceEpoch,
        'updated_at': updatedAt.millisecondsSinceEpoch,
        'deleted_at': deletedAt?.millisecondsSinceEpoch,
      };

  factory Document.fromMap(Map<String, Object?> map) {
    final deletedEpoch = map['deleted_at'] as int?;
    return Document(
      id: map['id'] as String,
      folderId: map['folder_id'] as String?,
      name: map['name'] as String,
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
      note: map['note'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['created_at'] as int,
        isUtc: true,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        map['updated_at'] as int,
        isUtc: true,
      ),
      deletedAt: deletedEpoch != null
          ? DateTime.fromMillisecondsSinceEpoch(deletedEpoch, isUtc: true)
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Document &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          folderId == other.folderId &&
          name == other.name &&
          isFavorite == other.isFavorite &&
          note == other.note &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          deletedAt == other.deletedAt;

  @override
  int get hashCode => Object.hash(
        id,
        folderId,
        name,
        isFavorite,
        note,
        createdAt,
        updatedAt,
        deletedAt,
      );
}
