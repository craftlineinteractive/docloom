import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:docloom/core/db/app_database.dart';
import 'package:docloom/core/errors/app_exception.dart';
import 'package:docloom/features/documents/data/sqlite_document_repository.dart';
import 'package:docloom/features/documents/domain/new_page.dart';
import 'package:docloom/features/folders/data/sqlite_folder_repository.dart';
import 'package:docloom/features/trash/data/sqlite_trash_repository.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  late AppDatabase db;
  late SqliteFolderRepository folderRepo;
  late SqliteDocumentRepository docRepo;
  late SqliteTrashRepository trashRepo;
  late DateTime fakeTime;

  DateTime clock() => fakeTime;

  setUp(() async {
    fakeTime = DateTime.utc(2026, 10, 11, 12, 0, 0);
    db = await AppDatabase.open(factory: databaseFactoryFfi, path: inMemoryDatabasePath);
    folderRepo = SqliteFolderRepository(db, clock: clock);
    docRepo = SqliteDocumentRepository(db, clock: clock);
    trashRepo = SqliteTrashRepository(db, clock: clock);
  });

  tearDown(() => db.close());

  test('doc in a trashed folder: getById returns null, listInFolder(folderId) is empty, rename throws NotFoundException, getPages is empty. After restoreFolder all of these work again', () async {
    final folder = await folderRepo.create(name: 'Work');
    final doc = await docRepo.createWithPages(
      id: 'd1',
      name: 'Contract',
      folderId: folder.id,
      pages: const [NewPage(id: 'p1', originalPath: 'p1.jpg')],
    );

    await folderRepo.moveToTrash(folder.id);

    expect(await docRepo.getById(doc.id), isNull);
    expect(await docRepo.listInFolder(folderId: folder.id), isEmpty);
    expect(() => docRepo.rename(doc.id, 'New Contract'), throwsA(isA<NotFoundException>()));
    expect(await docRepo.getPages(doc.id), isEmpty);

    await trashRepo.restoreFolder(folder.id);

    final restoredDoc = await docRepo.getById(doc.id);
    expect(restoredDoc, isNotNull);
    expect((await docRepo.listInFolder(folderId: folder.id)).length, 1);
    await docRepo.rename(doc.id, 'New Contract');
    expect((await docRepo.getById(doc.id))?.name, equals('New Contract'));
    expect((await docRepo.getPages(doc.id)).length, 1);
  });

  test('listTrashedFolders count excludes a document trashed on its own earlier', () async {
    final folder = await folderRepo.create(name: 'Invoices');
    final d1 = await docRepo.createWithPages(id: 'd1', name: 'Old Inv', folderId: folder.id, pages: const [NewPage(id: 'p1', originalPath: 'p1.jpg')]);
    await docRepo.createWithPages(id: 'd2', name: 'Active Inv', folderId: folder.id, pages: const [NewPage(id: 'p2', originalPath: 'p2.jpg')]);

    await docRepo.moveToTrash(d1.id);
    fakeTime = fakeTime.add(const Duration(hours: 1));
    await folderRepo.moveToTrash(folder.id);

    final trashedFolders = await trashRepo.listTrashedFolders();
    final folderSummary = trashedFolders.firstWhere((f) => f.folder.id == folder.id);
    expect(folderSummary.itemCount, equals(1));
  });

  test('deleteDocumentForever(active doc id) returns empty and the document still exists; deleteFolderForever(active folder id) the same', () async {
    final folder = await folderRepo.create(name: 'Active Folder');
    final doc = await docRepo.createWithPages(id: 'd-act', name: 'Doc', pages: const [NewPage(id: 'p', originalPath: 'p.jpg')]);

    final docRes = await trashRepo.deleteDocumentForever(doc.id);
    expect(docRes, isEmpty);
    expect(await docRepo.getById(doc.id), isNotNull);

    final folderRes = await trashRepo.deleteFolderForever(folder.id);
    expect(folderRes, isEmpty);
    expect(await folderRepo.getById(folder.id), isNotNull);
  });

  test('deleteDocumentForever on a document inside a trashed folder whose own deleted_at is NULL returns empty and changes nothing', () async {
    final folder = await folderRepo.create(name: 'Folder');
    final doc = await docRepo.createWithPages(id: 'd-in-trash', name: 'Doc', folderId: folder.id, pages: const [NewPage(id: 'p', originalPath: 'p.jpg')]);
    await folderRepo.moveToTrash(folder.id);

    final res = await trashRepo.deleteDocumentForever(doc.id);
    expect(res, isEmpty);

    final row = (await db.db.query('documents', where: 'id = ?', whereArgs: [doc.id])).first;
    expect(row['deleted_at'], isNull);
  });

  test('moveToTrash twice with the clock advanced between calls: deleted_at equals the FIRST time. Same for folders', () async {
    final folder = await folderRepo.create(name: 'F');
    final doc = await docRepo.createWithPages(id: 'd', name: 'D', pages: const [NewPage(id: 'p', originalPath: 'p.jpg')]);

    final time1 = fakeTime.millisecondsSinceEpoch;
    await folderRepo.moveToTrash(folder.id);
    await docRepo.moveToTrash(doc.id);

    fakeTime = fakeTime.add(const Duration(days: 2));
    await folderRepo.moveToTrash(folder.id);
    await docRepo.moveToTrash(doc.id);

    final fRow = (await db.db.query('folders', where: 'id = ?', whereArgs: [folder.id])).first;
    final dRow = (await db.db.query('documents', where: 'id = ?', whereArgs: [doc.id])).first;
    expect(fRow['deleted_at'], equals(time1));
    expect(dRow['deleted_at'], equals(time1));
  });

  test('restoreDocument on an active document changes nothing', () async {
    final doc = await docRepo.createWithPages(id: 'd-active', name: 'Active', pages: const [NewPage(id: 'p', originalPath: 'p.jpg')]);
    final origRow = (await db.db.query('documents', where: 'id = ?', whereArgs: [doc.id])).first;

    final result = await trashRepo.restoreDocument(doc.id);
    expect(result.restoredToRoot, isFalse);

    final newRow = (await db.db.query('documents', where: 'id = ?', whereArgs: [doc.id])).first;
    expect(newRow['deleted_at'], isNull);
    expect(newRow['updated_at'], equals(origRow['updated_at']));
  });
}
