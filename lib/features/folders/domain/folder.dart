import 'package:flutter/foundation.dart';

@immutable
class Folder {
  const Folder({
    required this.id,
    required this.name,
    this.colorIndex = 0,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String name;
  final int colorIndex;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Folder copyWith({
    String? id,
    String? name,
    int? colorIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Folder(
      id: id ?? this.id,
      name: name ?? this.name,
      colorIndex: colorIndex ?? this.colorIndex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Folder withDeletedAt(DateTime? deletedAt) {
    return Folder(
      id: id,
      name: name,
      colorIndex: colorIndex,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'color_index': colorIndex,
        'created_at': createdAt.millisecondsSinceEpoch,
        'updated_at': updatedAt.millisecondsSinceEpoch,
        'deleted_at': deletedAt?.millisecondsSinceEpoch,
      };

  factory Folder.fromMap(Map<String, Object?> map) {
    final deletedEpoch = map['deleted_at'] as int?;
    return Folder(
      id: map['id'] as String,
      name: map['name'] as String,
      colorIndex: (map['color_index'] as int?) ?? 0,
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
      other is Folder &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          colorIndex == other.colorIndex &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          deletedAt == other.deletedAt;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        colorIndex,
        createdAt,
        updatedAt,
        deletedAt,
      );
}
