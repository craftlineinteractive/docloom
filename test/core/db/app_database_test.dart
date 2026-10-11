import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:docloom/core/db/app_database.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  late AppDatabase database;

  setUp(() async {
    database = await AppDatabase.open(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('all 3 tables and 4 indexes exist in sqlite_master', () async {
    final tables = await database.db.query(
      'sqlite_master',
      columns: ['name'],
      where: 'type = ?',
      whereArgs: ['table'],
    );
    final tableNames = tables.map((e) => e['name'] as String).toSet();
    expect(tableNames, containsAll(['folders', 'documents', 'pages']));

    final indexes = await database.db.query(
      'sqlite_master',
      columns: ['name'],
      where: 'type = ?',
      whereArgs: ['index'],
    );
    final indexNames = indexes.map((e) => e['name'] as String).toSet();
    expect(
      indexNames,
      containsAll([
        'idx_documents_folder',
        'idx_documents_deleted',
        'idx_pages_document',
        'idx_folders_deleted',
      ]),
    );
  });

  test('PRAGMA foreign_keys returns 1', () async {
    final result = await database.db.rawQuery('PRAGMA foreign_keys;');
    expect(result.first.values.first, equals(1));
  });

  test('inserting a page for a non-existent document fails', () async {
    expect(
      () => database.db.insert('pages', {
        'id': 'p-1',
        'document_id': 'missing-doc-id',
        'position': 0,
        'original_path': 'docs/p1.jpg',
        'filter_id': 'original',
        'rotation': 0,
        'created_at': 1700000000000,
      }),
      throwsA(isA<DatabaseException>()),
    );
  });

  test('deleting a document cascades to its pages', () async {
    await database.db.insert('documents', {
      'id': 'doc-1',
      'name': 'Invoice',
      'is_favorite': 0,
      'created_at': 1700000000000,
      'updated_at': 1700000000000,
    });

    await database.db.insert('pages', {
      'id': 'page-1',
      'document_id': 'doc-1',
      'position': 0,
      'original_path': 'docs/p1.jpg',
      'filter_id': 'original',
      'rotation': 0,
      'created_at': 1700000000000,
    });
    await database.db.insert('pages', {
      'id': 'page-2',
      'document_id': 'doc-1',
      'position': 1,
      'original_path': 'docs/p2.jpg',
      'filter_id': 'original',
      'rotation': 0,
      'created_at': 1700000000001,
    });

    final beforePages = await database.db.query(
      'pages',
      where: 'document_id = ?',
      whereArgs: ['doc-1'],
    );
    expect(beforePages.length, equals(2));

    await database.db.delete('documents', where: 'id = ?', whereArgs: ['doc-1']);

    final afterPages = await database.db.query(
      'pages',
      where: 'document_id = ?',
      whereArgs: ['doc-1'],
    );
    expect(afterPages, isEmpty);
  });
}
