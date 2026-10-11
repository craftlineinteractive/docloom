import 'package:flutter/foundation.dart';
import 'document.dart';

@immutable
class DocumentSummary {
  const DocumentSummary({
    required this.document,
    required this.pageCount,
    this.coverPath,
  });

  final Document document;
  final int pageCount;
  final String? coverPath;

  DocumentSummary copyWith({
    Document? document,
    int? pageCount,
    String? coverPath,
  }) {
    return DocumentSummary(
      document: document ?? this.document,
      pageCount: pageCount ?? this.pageCount,
      coverPath: coverPath ?? this.coverPath,
    );
  }

  DocumentSummary withCoverPath(String? coverPath) => DocumentSummary(
        document: document,
        pageCount: pageCount,
        coverPath: coverPath,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentSummary &&
          runtimeType == other.runtimeType &&
          document == other.document &&
          pageCount == other.pageCount &&
          coverPath == other.coverPath;

  @override
  int get hashCode => Object.hash(document, pageCount, coverPath);
}
