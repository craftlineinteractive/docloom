import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:docloom/core/db/app_database.dart';
import 'package:docloom/core/storage/document_file_store.dart';
import 'package:docloom/features/documents/data/sqlite_document_repository.dart';
import 'package:docloom/features/documents/domain/new_page.dart';
import 'package:docloom/features/folders/data/sqlite_folder_repository.dart';
import 'package:docloom/features/trash/application/trash_service.dart';
import 'package:docloom/features/trash/data/sqlite_trash_repository.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  late AppDatabase db;
  late Directory tempDir;
  late DocumentFileStore fileStore;
  late SqliteFolderRepository folderRepo;
  late SqliteDocumentRepository docRepo;
  late SqliteTrashRepository trashRepo;
  late TrashService trashService;
  late DateTime currentTime;

  DateTime fakeClock() => currentTime;

  setUp(() async {
    currentTime = DateTime.utc(2025, 1, 1, 12, 0);
    db = await AppDatabase.open(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    tempDir = await Directory.systemTemp.createTemp('storage_lifecycle_');
    fileStore = DocumentFileStore(tempDir);
    folderRepo = SqliteFolderRepository(db, clock: fakeClock);
    docRepo = SqliteDocumentRepository(db, clock: fakeClock);
    trashRepo = SqliteTrashRepository(db, clock: fakeClock);
    trashService = TrashService(trashRepo, docRepo, fileStore, clock: fakeClock);
  });



  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('purgeExpired retains at 29 days and cleans DB rows and files at 31 days', () async {
    const docId = 'doc-retention-test';
    final p1 = await fileStore.writeEdited(documentId: docId, pageId: 'p1', bytes: [1, 2, 3]);
    final p2 = await fileStore.writeEdited(documentId: docId, pageId: 'p2', bytes: [4, 5, 6]);

    await docRepo.createWithPages(
      id: docId,
      name: 'Retention Doc',
      pages: [NewPage(id: 'p1', originalPath: p1), NewPage(id: 'p2', originalPath: p2)],
    );

    expect(await fileStore.resolve(p1).exists(), isTrue);
    expect(await fileStore.resolve(p2).exists(), isTrue);

    await docRepo.moveToTrash(docId);

    // Advance 29 days
    currentTime = currentTime.add(const Duration(days: 29));
    final purged29 = await trashService.purgeExpired();
    expect(purged29, 0);
    expect((await trashRepo.listTrashedDocuments()).length, 1);
    expect(await fileStore.resolve(p1).exists(), isTrue);

    // Advance 2 more days (31 days total)
    currentTime = currentTime.add(const Duration(days: 2));
    final purged31 = await trashService.purgeExpired();
    expect(purged31, 1);
    expect(await trashRepo.listTrashedDocuments(), isEmpty);
    expect(await fileStore.resolve(p1).exists(), isFalse);
    expect(await fileStore.resolve(p2).exists(), isFalse);
    expect(await fileStore.countFiles(), 0);
  });

  test('deleteFolderForever removes DB rows and files of documents inside folder', () async {
    final folder = await folderRepo.create(name: 'Target Folder');
    const docId = 'doc-folder-test';
    final p1 = await fileStore.writeEdited(documentId: docId, pageId: 'p1', bytes: [10, 20]);
    await docRepo.createWithPages(
      id: docId,
      name: 'Folder Doc',
      folderId: folder.id,
      pages: [NewPage(id: 'p1', originalPath: p1)],
    );

    expect(await fileStore.resolve(p1).exists(), isTrue);

    await folderRepo.moveToTrash(folder.id);
    await trashService.deleteFolderForever(folder.id);

    expect(await folderRepo.getById(folder.id), isNull);
    expect(await docRepo.getById(docId), isNull);
    expect(await fileStore.resolve(p1).exists(), isFalse);
    expect(await fileStore.countFiles(), 0);
  });

  test('deleteDocumentForever and emptyTrash remove files on disk', () async {
    const doc1Id = 'doc-1';
    const doc2Id = 'doc-2';
    final p1 = await fileStore.writeEdited(documentId: doc1Id, pageId: 'p1', bytes: [1]);
    final p2 = await fileStore.writeEdited(documentId: doc2Id, pageId: 'p2', bytes: [2]);

    await docRepo.createWithPages(id: doc1Id, name: 'Doc 1', pages: [NewPage(id: 'p1', originalPath: p1)]);
    await docRepo.createWithPages(id: doc2Id, name: 'Doc 2', pages: [NewPage(id: 'p2', originalPath: p2)]);

    await docRepo.moveToTrash(doc1Id);
    await docRepo.moveToTrash(doc2Id);

    await trashService.deleteDocumentForever(doc1Id);
    expect(await fileStore.resolve(p1).exists(), isFalse);
    expect(await fileStore.resolve(p2).exists(), isTrue);

    await trashService.emptyTrash();
    expect(await fileStore.resolve(p2).exists(), isFalse);
    expect(await fileStore.countFiles(), 0);
  });

  test('active document survives deleteDocumentForever and active folder survives deleteFolderForever', () async {
    final folder = await folderRepo.create(name: 'Active Folder');
    const docId = 'doc-active';
    final p1 = await fileStore.writeEdited(documentId: docId, pageId: 'p1', bytes: [7, 8]);
    await docRepo.createWithPages(id: docId, name: 'Active Doc', folderId: folder.id, pages: [NewPage(id: 'p1', originalPath: p1)]);

    await trashService.deleteDocumentForever(docId);
    expect(await docRepo.getById(docId), isNotNull);
    expect(await fileStore.resolve(p1).exists(), isTrue);

    await trashService.deleteFolderForever(folder.id);
    expect(await folderRepo.getById(folder.id), isNotNull);
    expect(await docRepo.getById(docId), isNotNull);
    expect(await fileStore.resolve(p1).exists(), isTrue);
  });
}

