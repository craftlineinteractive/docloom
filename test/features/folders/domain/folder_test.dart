import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/features/folders/domain/folder.dart';
import 'package:docloom/features/folders/domain/folder_summary.dart';

void main() {
  group('Folder', () {
    final now = DateTime.utc(2026, 10, 11, 12, 0, 0);

    test('toMap and fromMap round trip with deletedAt', () {
      final folder = Folder(
        id: 'f-1',
        name: 'Client Files',
        colorIndex: 2,
        createdAt: now,
        updatedAt: now,
        deletedAt: now.add(const Duration(hours: 1)),
      );

      final map = folder.toMap();
      expect(map['id'], equals('f-1'));
      expect(map['name'], equals('Client Files'));
      expect(map['color_index'], equals(2));
      expect(map['created_at'], equals(now.millisecondsSinceEpoch));
      expect(map['deleted_at'], equals(now.add(const Duration(hours: 1)).millisecondsSinceEpoch));

      final restored = Folder.fromMap(map);
      expect(restored, equals(folder));
    });

    test('toMap and fromMap round trip with null deletedAt', () {
      final folder = Folder(
        id: 'f-2',
        name: 'Personal IDs',
        colorIndex: 0,
        createdAt: now,
        updatedAt: now,
        deletedAt: null,
      );

      final map = folder.toMap();
      expect(map['deleted_at'], isNull);

      final restored = Folder.fromMap(map);
      expect(restored, equals(folder));
      expect(restored.deletedAt, isNull);
    });

    test('withDeletedAt(null) really clears the value', () {
      final folder = Folder(
        id: 'f-3',
        name: 'Taxes',
        createdAt: now,
        updatedAt: now,
        deletedAt: now,
      );

      expect(folder.deletedAt, isNotNull);
      final cleared = folder.withDeletedAt(null);
      expect(cleared.deletedAt, isNull);
      expect(cleared.id, equals(folder.id));
      expect(cleared.name, equals(folder.name));
    });

    test('copyWith updates specified fields', () {
      final folder = Folder(
        id: 'f-4',
        name: 'Bills',
        createdAt: now,
        updatedAt: now,
      );

      final updated = folder.copyWith(name: 'Paid Bills', colorIndex: 3);
      expect(updated.name, equals('Paid Bills'));
      expect(updated.colorIndex, equals(3));
      expect(updated.id, equals('f-4'));
    });
  });

  group('FolderSummary', () {
    test('instantiates and supports equality and copyWith', () {
      final now = DateTime.utc(2026, 10, 11);
      final folder = Folder(
        id: 'f-5',
        name: 'Receipts',
        createdAt: now,
        updatedAt: now,
      );
      final summary = FolderSummary(folder: folder, itemCount: 5);

      expect(summary.itemCount, equals(5));
      expect(summary.folder, equals(folder));

      final updated = summary.copyWith(itemCount: 6);
      expect(updated.itemCount, equals(6));
      expect(summary == updated, isFalse);
    });
  });
}
