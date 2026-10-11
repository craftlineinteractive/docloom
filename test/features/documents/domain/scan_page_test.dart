import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/features/documents/domain/scan_page.dart';

void main() {
  group('ScanPage', () {
    final now = DateTime.utc(2026, 10, 11, 14, 0, 0);

    test('toMap and fromMap round trip with editedPath', () {
      final page = ScanPage(
        id: 'pg-1',
        documentId: 'doc-1',
        position: 0,
        originalPath: 'docs/p1_orig.jpg',
        editedPath: 'docs/p1_edited.jpg',
        filterId: 'magic',
        rotation: 90,
        createdAt: now,
      );

      final map = page.toMap();
      expect(map['id'], equals('pg-1'));
      expect(map['document_id'], equals('doc-1'));
      expect(map['position'], equals(0));
      expect(map['original_path'], equals('docs/p1_orig.jpg'));
      expect(map['edited_path'], equals('docs/p1_edited.jpg'));
      expect(map['filter_id'], equals('magic'));
      expect(map['rotation'], equals(90));
      expect(map['created_at'], equals(now.millisecondsSinceEpoch));

      final restored = ScanPage.fromMap(map);
      expect(restored, equals(page));
      expect(restored.displayPath, equals('docs/p1_edited.jpg'));
    });

    test('displayPath returns originalPath when editedPath is null', () {
      final page = ScanPage(
        id: 'pg-2',
        documentId: 'doc-1',
        position: 1,
        originalPath: 'docs/p2_orig.jpg',
        editedPath: null,
        createdAt: now,
      );

      final map = page.toMap();
      expect(map['edited_path'], isNull);

      final restored = ScanPage.fromMap(map);
      expect(restored, equals(page));
      expect(restored.displayPath, equals('docs/p2_orig.jpg'));
    });

    test('withEditedPath(null) really clears editedPath', () {
      final page = ScanPage(
        id: 'pg-3',
        documentId: 'doc-2',
        position: 0,
        originalPath: 'docs/orig.jpg',
        editedPath: 'docs/edited.jpg',
        createdAt: now,
      );

      expect(page.editedPath, isNotNull);
      expect(page.displayPath, equals('docs/edited.jpg'));

      final cleared = page.withEditedPath(null);
      expect(cleared.editedPath, isNull);
      expect(cleared.displayPath, equals('docs/orig.jpg'));
      expect(cleared.id, equals(page.id));
    });

    test('copyWith updates specified fields', () {
      final page = ScanPage(
        id: 'pg-4',
        documentId: 'doc-3',
        position: 2,
        originalPath: 'docs/orig.jpg',
        createdAt: now,
      );

      final updated = page.copyWith(rotation: 180, filterId: 'bw');
      expect(updated.rotation, equals(180));
      expect(updated.filterId, equals('bw'));
      expect(updated.position, equals(2));
    });
  });
}
