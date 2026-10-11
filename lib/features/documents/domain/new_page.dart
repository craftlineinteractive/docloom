import 'package:flutter/foundation.dart';

@immutable
class NewPage {
  const NewPage({
    required this.id,
    required this.originalPath,
  });

  final String id;
  final String originalPath;

  NewPage copyWith({
    String? id,
    String? originalPath,
  }) {
    return NewPage(
      id: id ?? this.id,
      originalPath: originalPath ?? this.originalPath,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewPage &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          originalPath == other.originalPath;

  @override
  int get hashCode => Object.hash(id, originalPath);
}
