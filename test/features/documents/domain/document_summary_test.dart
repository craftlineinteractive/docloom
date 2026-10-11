import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/features/documents/domain/document.dart';
import 'package:docloom/features/documents/domain/document_sort.dart';
import 'package:docloom/features/documents/domain/document_summary.dart';
import 'package:docloom/features/documents/domain/new_page.dart';

void main() {
  group('DocumentSummary', () {
    final now = DateTime.utc(2026, 10, 11);
    final doc = Document(
      id: 'doc-s',
      name: 'Summary Doc',
      createdAt: now,
      updatedAt: now,
    );

    test('instantiates and supports equality and copyWith', () {
      final summary = DocumentSummary(
        document: doc,
        pageCount: 3,
        coverPath: 'covers/cover.jpg',
      );

      expect(summary.pageCount, equals(3));
      expect(summary.coverPath, equals('covers/cover.jpg'));
      expect(summary.document, equals(doc));

      final updated = summary.copyWith(pageCount: 4);
      expect(updated.pageCount, equals(4));
      expect(updated.coverPath, equals('covers/cover.jpg'));

      final cleared = summary.withCoverPath(null);
      expect(cleared.coverPath, isNull);
    });
  });

  group('NewPage', () {
    test('instantiates with id and originalPath and supports copyWith', () {
      const newPage = NewPage(id: 'np-1', originalPath: 'temp/raw.jpg');
      expect(newPage.id, equals('np-1'));
      expect(newPage.originalPath, equals('temp/raw.jpg'));

      final copy = newPage.copyWith(originalPath: 'temp/moved.jpg');
      expect(copy.originalPath, equals('temp/moved.jpg'));
      expect(copy.id, equals('np-1'));
    });
  });

  group('DocumentSort', () {
    test('contains all expected enum values', () {
      expect(DocumentSort.values, containsAll([
        DocumentSort.modifiedDesc,
        DocumentSort.modifiedAsc,
        DocumentSort.nameAsc,
        DocumentSort.nameDesc,
      ]));
    });
  });
}
