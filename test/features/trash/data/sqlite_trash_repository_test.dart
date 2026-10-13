import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:docloom/core/db/app_database.dart';
import 'package:docloom/features/trash/data/sqlite_trash_repository.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  late AppDatabase db;
  late SqliteTrashRepository repository;
  late DateTime fakeTime;

  DateTime clock() => fakeTime;

  setUp(() async {
    fakeTime = DateTime.utc(2026, 10, 11, 12, 0, 0);
    db = await AppDatabase.open(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    repository = SqliteTrashRepository(db, clock: clock);
  });

  tearDown(() => db.close());

  test('restoreDocument restores to folder or to root if folder is trashed', () async {
    await db.db.insert('folders', {'id': 'f1', 'name': 'Active', 'created_at': 0, 'updated_at': 0});
    await db.db.insert('documents', {'id': 'd1', 'folder_id': 'f1', 'name': 'Doc1', 'created_at': 0, 'updated_at': 0, 'deleted_at': 100});

    final res1 = await repository.restoreDocument('d1');
    expect(res1.restoredToRoot, isFalse);
    var doc = (await db.db.query('documents', where: 'id = ?', whereArgs: ['d1'])).first;
    expect(doc['deleted_at'], isNull);
    expect(doc['folder_id'], equals('f1'));

    // Now trash folder f1 and re-trash d1
    await db.db.update('folders', {'deleted_at': 200}, where: 'id = ?', whereArgs: ['f1']);
    await db.db.update('documents', {'deleted_at': 300}, where: 'id = ?', whereArgs: ['d1']);

    final res2 = await repository.restoreDocument('d1');
    expect(res2.restoredToRoot, isTrue);
    doc = (await db.db.query('documents', where: 'id = ?', whereArgs: ['d1'])).first;
    expect(doc['deleted_at'], isNull);
    expect(doc['folder_id'], isNull);
  });

  test('restoreFolder clears deleted_at on folder', () async {
    await db.db.insert('folders', {'id': 'f2', 'name': 'Work', 'created_at': 0, 'updated_at': 0, 'deleted_at': 100});
    await repository.restoreFolder('f2');

    final folder = (await db.db.query('folders', where: 'id = ?', whereArgs: ['f2'])).first;
    expect(folder['deleted_at'], isNull);
  });

  test('deleteDocumentForever removes document and cascades to pages', () async {
    await db.db.insert('documents', {'id': 'd-del', 'name': 'D', 'created_at': 0, 'updated_at': 0, 'deleted_at': 100});
    await db.db.insert('pages', {'id': 'p-del', 'document_id': 'd-del', 'position': 0, 'original_path': 'p.jpg', 'created_at': 0});

    final ids = await repository.deleteDocumentForever('d-del');
    expect(ids, equals(['d-del']));
    expect(await db.db.query('documents', where: 'id = ?', whereArgs: ['d-del']), isEmpty);
    expect(await db.db.query('pages', where: 'id = ?', whereArgs: ['p-del']), isEmpty);
  });

  test('deleteFolderForever removes folder and documents inside', () async {
    await db.db.insert('folders', {'id': 'f-del', 'name': 'F', 'created_at': 0, 'updated_at': 0, 'deleted_at': 100});
    await db.db.insert('documents', {'id': 'd-in-f', 'folder_id': 'f-del', 'name': 'Inside', 'created_at': 0, 'updated_at': 0});

    final deletedIds = await repository.deleteFolderForever('f-del');
    expect(deletedIds, equals(['d-in-f']));
    expect(await db.db.query('folders', where: 'id = ?', whereArgs: ['f-del']), isEmpty);
    expect(await db.db.query('documents', where: 'id = ?', whereArgs: ['d-in-f']), isEmpty);
  });

  test('emptyTrash deletes all trashed documents and folders and their documents', () async {
    await db.db.insert('folders', {'id': 'f-tr', 'name': 'TrashF', 'created_at': 0, 'updated_at': 0, 'deleted_at': 100});
    await db.db.insert('documents', {'id': 'd-in-tr', 'folder_id': 'f-tr', 'name': 'InTr', 'created_at': 0, 'updated_at': 0});
    await db.db.insert('documents', {'id': 'd-lone-tr', 'name': 'Lone', 'created_at': 0, 'updated_at': 0, 'deleted_at': 100});

    final deleted = await repository.emptyTrash();
    expect(deleted, containsAll(['d-in-tr', 'd-lone-tr']));
    expect(await db.db.query('folders', where: 'deleted_at IS NOT NULL'), isEmpty);
    expect(await db.db.query('documents'), isEmpty);
  });

  test('purgeExpired respects retention and purges active documents of expired folders', () async {
    const retention = Duration(days: 30);
    final nowMs = fakeTime.millisecondsSinceEpoch;
    final ms29DaysAgo = fakeTime.subtract(const Duration(days: 29)).millisecondsSinceEpoch;
    final ms31DaysAgo = fakeTime.subtract(const Duration(days: 31)).millisecondsSinceEpoch;

    // Item trashed 29 days ago (keep)
    await db.db.insert('documents', {'id': 'd-keep', 'name': 'Keep', 'created_at': 0, 'updated_at': 0, 'deleted_at': ms29DaysAgo});
    // Item trashed 31 days ago (purge)
    await db.db.insert('documents', {'id': 'd-purge', 'name': 'Purge', 'created_at': 0, 'updated_at': 0, 'deleted_at': ms31DaysAgo});

    // Folder trashed 31 days ago with active document
    await db.db.insert('folders', {'id': 'f-old', 'name': 'OldF', 'created_at': 0, 'updated_at': 0, 'deleted_at': ms31DaysAgo});
    await db.db.insert('documents', {'id': 'd-in-old', 'folder_id': 'f-old', 'name': 'ActiveInOld', 'created_at': 0, 'updated_at': nowMs});

    final purged = await repository.purgeExpired(retention);
    expect(purged, containsAll(['d-purge', 'd-in-old']));
    expect(purged, isNot(contains('d-keep')));

    expect(await db.db.query('documents', where: 'id = ?', whereArgs: ['d-keep']), isNotEmpty);
    expect(await db.db.query('documents', where: 'id = ?', whereArgs: ['d-purge']), isEmpty);
    expect(await db.db.query('documents', where: 'id = ?', whereArgs: ['d-in-old']), isEmpty);
    expect(await db.db.query('folders', where: 'id = ?', whereArgs: ['f-old']), isEmpty);
  });

  test('restoreDocuments restores multiple documents in one atomic transaction', () async {
    await db.db.insert('documents', {'id': 'd-b1', 'name': 'B1', 'created_at': 0, 'updated_at': 0, 'deleted_at': 100});
    await db.db.insert('documents', {'id': 'd-b2', 'name': 'B2', 'created_at': 0, 'updated_at': 0, 'deleted_at': 100});

    await repository.restoreDocuments(['d-b1', 'd-b2']);

    final rows = await db.db.query('documents', where: 'id IN (?, ?)', whereArgs: ['d-b1', 'd-b2']);
    expect(rows.length, equals(2));
    expect(rows.every((d) => d['deleted_at'] == null), isTrue);
  });
}
