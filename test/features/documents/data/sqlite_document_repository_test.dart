import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:docloom/core/db/app_database.dart';
import 'package:docloom/core/errors/app_exception.dart';
import 'package:docloom/features/documents/data/sqlite_document_repository.dart';
import 'package:docloom/features/documents/domain/document_sort.dart';
import 'package:docloom/features/documents/domain/new_page.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  late AppDatabase db;
  late SqliteDocumentRepository repository;
  late DateTime fakeTime;

  DateTime clock() => fakeTime;

  setUp(() async {
    fakeTime = DateTime.utc(2026, 10, 11, 12, 0, 0);
    db = await AppDatabase.open(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    repository = SqliteDocumentRepository(db, clock: clock);
  });

  tearDown(() => db.close());

  test('createWithPages creates doc and sets positions 0..n-1', () async {
    final doc = await repository.createWithPages(
      id: 'd1',
      name: '  Receipt  ',
      pages: const [
        NewPage(id: 'p1', originalPath: 'p1.jpg'),
        NewPage(id: 'p2', originalPath: 'p2.jpg'),
      ],
    );
    expect(doc.name, equals('Receipt'));
    final pages = await repository.getPages('d1');
    expect(pages.length, equals(2));
    expect(pages[0].position, equals(0));
    expect(pages[1].position, equals(1));
  });

  test('createWithPages rejects empty name, empty pages, and trashed folder', () async {
    expect(() => repository.createWithPages(id: 'd2', name: '  ', pages: const [NewPage(id: 'p', originalPath: 'p.jpg')]), throwsA(isA<ValidationException>()));
    expect(() => repository.createWithPages(id: 'd3', name: 'Valid', pages: const []), throwsA(isA<ValidationException>()));

    await db.db.insert('folders', {
      'id': 'f-trashed',
      'name': 'Trash Folder',
      'created_at': 0,
      'updated_at': 0,
      'deleted_at': 100,
    });
    expect(() => repository.createWithPages(id: 'd4', name: 'Valid', folderId: 'f-trashed', pages: const [NewPage(id: 'p', originalPath: 'p.jpg')]), throwsA(isA<ValidationException>()));
  });

  test('root list vs folder list and all 4 sorts (NOCASE)', () async {
    await repository.createWithPages(id: 'd1', name: 'beta', pages: const [NewPage(id: 'p1', originalPath: 'p1.jpg')]);
    fakeTime = fakeTime.add(const Duration(seconds: 10));
    await repository.createWithPages(id: 'd2', name: 'Alpha', pages: const [NewPage(id: 'p2', originalPath: 'p2.jpg')]);

    await db.db.insert('folders', {'id': 'f1', 'name': 'Active Folder', 'created_at': 0, 'updated_at': 0});
    await repository.createWithPages(id: 'd3', name: 'Inside', folderId: 'f1', pages: const [NewPage(id: 'p3', originalPath: 'p3.jpg')]);

    final rootList = await repository.listInFolder(sort: DocumentSort.nameAsc);
    expect(rootList.map((e) => e.document.name).toList(), equals(['Alpha', 'beta']));

    final descList = await repository.listInFolder(sort: DocumentSort.modifiedDesc);
    expect(descList.first.document.name, equals('Alpha'));

    final ascList = await repository.listInFolder(sort: DocumentSort.modifiedAsc);
    expect(ascList.first.document.name, equals('beta'));

    final nameDesc = await repository.listInFolder(sort: DocumentSort.nameDesc);
    expect(nameDesc.first.document.name, equals('beta'));

    final folderList = await repository.listInFolder(folderId: 'f1');
    expect(folderList.length, equals(1));
    expect(folderList.first.document.name, equals('Inside'));
  });

  test('setFavorite and moveToFolder validate targets and update state', () async {
    final doc = await repository.createWithPages(id: 'd-fav', name: 'Doc', pages: const [NewPage(id: 'p', originalPath: 'p.jpg')]);
    await repository.setFavorite(doc.id, true);
    expect((await repository.getById(doc.id))?.isFavorite, isTrue);

    await db.db.insert('folders', {'id': 'f-trashed', 'name': 'Trashed', 'created_at': 0, 'updated_at': 0, 'deleted_at': 100});
    expect(() => repository.moveToFolder(doc.id, 'f-trashed'), throwsA(isA<ValidationException>()));

    await db.db.insert('folders', {'id': 'f-valid', 'name': 'Valid', 'created_at': 0, 'updated_at': 0});
    await repository.moveToFolder(doc.id, 'f-valid');
    expect((await repository.getById(doc.id))?.folderId, equals('f-valid'));
  });

  test('moveToTrash hides document from listInFolder and getById', () async {
    final doc = await repository.createWithPages(id: 'd-del', name: 'Del', pages: const [NewPage(id: 'p', originalPath: 'p.jpg')]);
    await repository.moveToTrash(doc.id);

    expect(await repository.getById(doc.id), isNull);
    final list = await repository.listInFolder();
    expect(list.any((d) => d.document.id == doc.id), isFalse);
  });

  test('existingIds returns existing active and trashed ids, empty set for empty input', () async {
    expect(await repository.existingIds(const []), isEmpty);

    final d1 = await repository.createWithPages(id: 'd-act', name: 'Act', pages: const [NewPage(id: 'p1', originalPath: 'p1.jpg')]);
    final d2 = await repository.createWithPages(id: 'd-tr', name: 'Tr', pages: const [NewPage(id: 'p2', originalPath: 'p2.jpg')]);
    await repository.moveToTrash(d2.id);

    final ids = await repository.existingIds([d1.id, d2.id, 'd-missing']);
    expect(ids, equals({d1.id, d2.id}));
  });
}

