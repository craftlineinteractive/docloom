import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:docloom/core/db/app_database.dart';
import 'package:docloom/features/documents/data/sqlite_document_repository.dart';
import 'package:docloom/features/documents/domain/new_page.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  late AppDatabase db;
  late SqliteDocumentRepository repository;

  setUp(() async {
    db = await AppDatabase.open(factory: databaseFactoryFfi, path: inMemoryDatabasePath);
    repository = SqliteDocumentRepository(db);
  });

  tearDown(() => db.close());

  test('searchByName returns empty list on empty or whitespace query', () async {
    expect(await repository.searchByName(''), isEmpty);
    expect(await repository.searchByName('   '), isEmpty);
  });

  test('searchByName matches case-insensitively and returns folderName', () async {
    await db.db.insert('folders', {'id': 'f1', 'name': 'Finances', 'created_at': 0, 'updated_at': 0});
    await repository.createWithPages(id: 'd1', name: 'Invoice October', folderId: 'f1', pages: const [NewPage(id: 'p1', originalPath: 'p1.jpg')]);
    await repository.createWithPages(id: 'd2', name: 'Random Notes', pages: const [NewPage(id: 'p2', originalPath: 'p2.jpg')]);

    final results = await repository.searchByName('invoice');
    expect(results.length, equals(1));
    expect(results.first.document.name, equals('Invoice October'));
    expect(results.first.folderName, equals('Finances'));
    expect(results.first.pageCount, equals(1));
  });

  test('searchByName escapes percent and underscore wildcards', () async {
    await repository.createWithPages(id: 'd1', name: '100% Cotton', pages: const [NewPage(id: 'p1', originalPath: 'p1.jpg')]);
    await repository.createWithPages(id: 'd2', name: '1000 Cotton', pages: const [NewPage(id: 'p2', originalPath: 'p2.jpg')]);
    await repository.createWithPages(id: 'd3', name: 'a_b test', pages: const [NewPage(id: 'p3', originalPath: 'p3.jpg')]);
    await repository.createWithPages(id: 'd4', name: 'axb test', pages: const [NewPage(id: 'p4', originalPath: 'p4.jpg')]);

    final percentResults = await repository.searchByName('100%');
    expect(percentResults.map((r) => r.document.id).toList(), equals(['d1']));

    final abResults = await repository.searchByName('a_b');
    expect(abResults.map((r) => r.document.id).toList(), equals(['d3']));
  });

  test('searchByName excludes trashed docs and docs in trashed folders', () async {
    await db.db.insert('folders', {'id': 'f-tr', 'name': 'Old', 'created_at': 0, 'updated_at': 0});
    await repository.createWithPages(id: 'd-act', name: 'Contract A', pages: const [NewPage(id: 'p1', originalPath: 'p1.jpg')]);
    await repository.createWithPages(id: 'd-in-tr', name: 'Contract B', folderId: 'f-tr', pages: const [NewPage(id: 'p2', originalPath: 'p2.jpg')]);
    await db.db.update('folders', {'deleted_at': 100}, where: 'id = ?', whereArgs: ['f-tr']);
    final dTr = await repository.createWithPages(id: 'd-tr', name: 'Contract C', pages: const [NewPage(id: 'p3', originalPath: 'p3.jpg')]);
    await repository.moveToTrash(dTr.id);

    final results = await repository.searchByName('Contract');
    expect(results.length, equals(1));
    expect(results.first.document.id, equals('d-act'));
  });
}
