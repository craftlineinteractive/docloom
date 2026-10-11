import 'package:flutter/foundation.dart';

@immutable
class RestoreResult {
  const RestoreResult({required this.restoredToRoot});

  final bool restoredToRoot;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RestoreResult &&
          runtimeType == other.runtimeType &&
          restoredToRoot == other.restoredToRoot;

  @override
  int get hashCode => restoredToRoot.hashCode;
}
