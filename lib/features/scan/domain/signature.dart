import 'package:flutter/foundation.dart';

@immutable
class Signature {
  const Signature({
    required this.id,
    required this.path,
    required this.createdAt,
  });

  final String id;
  final String path;
  final int createdAt;

  Map<String, dynamic> toMap() => {
        'id': id,
        'path': path,
        'created_at': createdAt,
      };

  factory Signature.fromMap(Map<String, dynamic> map) => Signature(
        id: map['id'] as String,
        path: map['path'] as String,
        createdAt: (map['created_at'] as num).toInt(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Signature &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          path == other.path &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(id, path, createdAt);
}
