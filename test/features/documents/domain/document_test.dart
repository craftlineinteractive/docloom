import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/features/documents/domain/document.dart';

void main() {
  group('Document', () {
    final now = DateTime.utc(2026, 10, 11, 10, 30, 0);

    test('toMap and fromMap round trip with all fields populated and isFavorite true', () {
      final document = Document(
        id: 'doc-100',
        folderId: 'folder-1',
        name: 'Passport Scan',
        isFavorite: true,
        note: 'Valid until 2030',
        createdAt: now,
        updatedAt: now,
        deletedAt: now.add(const Duration(days: 7)),
      );

      final map = document.toMap();
      expect(map['id'], equals('doc-100'));
      expect(map['folder_id'], equals('folder-1'));
      expect(map['name'], equals('Passport Scan'));
      expect(map['is_favorite'], equals(1));
      expect(map['note'], equals('Valid until 2030'));
      expect(map['created_at'], equals(now.millisecondsSinceEpoch));
      expect(map['deleted_at'], equals(now.add(const Duration(days: 7)).millisecondsSinceEpoch));

      final restored = Document.fromMap(map);
      expect(restored, equals(document));
      expect(restored.isFavorite, isTrue);
    });

    test('toMap and fromMap round trip with nullables null and isFavorite false', () {
      final document = Document(
        id: 'doc-101',
        folderId: null,
        name: 'Grocery Receipt',
        isFavorite: false,
        note: null,
        createdAt: now,
        updatedAt: now,
        deletedAt: null,
      );

      final map = document.toMap();
      expect(map['folder_id'], isNull);
      expect(map['is_favorite'], equals(0));
      expect(map['note'], isNull);
      expect(map['deleted_at'], isNull);

      final restored = Document.fromMap(map);
      expect(restored, equals(document));
      expect(restored.isFavorite, isFalse);
      expect(restored.folderId, isNull);
      expect(restored.note, isNull);
      expect(restored.deletedAt, isNull);
    });

    test('withDeletedAt(null) really clears the value', () {
      final document = Document(
        id: 'doc-102',
        name: 'Tax Form',
        createdAt: now,
        updatedAt: now,
        deletedAt: now,
      );

      expect(document.deletedAt, isNotNull);
      final restored = document.withDeletedAt(null);
      expect(restored.deletedAt, isNull);
      expect(restored.id, equals(document.id));
    });

    test('withFolderId(null) clears folderId', () {
      final document = Document(
        id: 'doc-103',
        folderId: 'folder-abc',
        name: 'Deed',
        createdAt: now,
        updatedAt: now,
      );

      expect(document.folderId, equals('folder-abc'));
      final cleared = document.withFolderId(null);
      expect(cleared.folderId, isNull);
      expect(cleared.name, equals('Deed'));
    });

    test('withNote(null) clears note', () {
      final document = Document(
        id: 'doc-104',
        name: 'Contract',
        note: 'Urgent review',
        createdAt: now,
        updatedAt: now,
      );

      expect(document.note, equals('Urgent review'));
      final cleared = document.withNote(null);
      expect(cleared.note, isNull);
      expect(cleared.name, equals('Contract'));
    });

    test('copyWith updates fields without clearing nullables', () {
      final document = Document(
        id: 'doc-105',
        folderId: 'folder-1',
        name: 'Old Name',
        isFavorite: false,
        createdAt: now,
        updatedAt: now,
      );

      final updated = document.copyWith(name: 'New Name', isFavorite: true);
      expect(updated.name, equals('New Name'));
      expect(updated.isFavorite, isTrue);
      expect(updated.folderId, equals('folder-1'));
    });
  });
}
