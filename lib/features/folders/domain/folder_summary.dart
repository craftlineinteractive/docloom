import 'package:flutter/foundation.dart';
import 'folder.dart';

@immutable
class FolderSummary {
  const FolderSummary({
    required this.folder,
    required this.itemCount,
  });

  final Folder folder;
  final int itemCount;

  FolderSummary copyWith({
    Folder? folder,
    int? itemCount,
  }) {
    return FolderSummary(
      folder: folder ?? this.folder,
      itemCount: itemCount ?? this.itemCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FolderSummary &&
          runtimeType == other.runtimeType &&
          folder == other.folder &&
          itemCount == other.itemCount;

  @override
  int get hashCode => Object.hash(folder, itemCount);
}
