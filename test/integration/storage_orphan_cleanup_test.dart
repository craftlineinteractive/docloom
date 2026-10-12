import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:docloom/core/db/app_database.dart';
import 'package:docloom/core/storage/document_file_store.dart';
import 'package:docloom/features/documents/data/sqlite_document_repository.dart';
import 'package:docloom/features/documents/domain/new_page.dart';
import 'package:docloom/features/trash/application/trash_service.dart';
import 'package:docloom/features/trash/data/sqlite_trash_repository.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  late AppDatabase db;
  late Directory tempDir;
  late DocumentFileStore fileStore;
  late SqliteDocumentRepository docRepo;
  late SqliteTrashRepository trashRepo;
  late TrashService trashService;

  setUp(() async {
    db = await AppDatabase.open(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    tempDir = await Directory.systemTemp.createTemp('orphan_cleanup_');
    fileStore = DocumentFileStore(tempDir);
    docRepo = SqliteDocumentRepository(db);
    trashRepo = SqliteTrashRepository(db);
    trashService = TrashService(trashRepo, docRepo, fileStore);
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  test('empty repository result touches no files', () async {
    final p1 = await fileStore.writeEdited(documentId: 'doc1', pageId: 'p1', bytes: [1]);
    final p2 = await fileStore.writeEdited(documentId: 'doc2', pageId: 'p2', bytes: [2]);

    await docRepo.createWithPages(id: 'doc1', name: 'Active', pages: [NewPage(id: 'p1', originalPath: p1)]);
    await docRepo.createWithPages(id: 'doc2', name: 'Trashed', pages: [NewPage(id: 'p2', originalPath: p2)]);

    await docRepo.moveToTrash('doc2');

    // Calling deleteDocumentForever on active doc returns [] from repo
    await trashService.deleteDocumentForever('doc1');

    expect(await fileStore.resolve(p1).exists(), isTrue);
    expect(await fileStore.resolve(p2).exists(), isTrue);
    expect(await fileStore.listDocumentDirIds(), containsAll(['doc1', 'doc2']));
  });

  test('cleanOrphanDirectories removes orphan dir and preserves active and trashed dirs', () async {
    final pActive = await fileStore.writeEdited(documentId: 'active-doc', pageId: 'pa', bytes: [10]);
    final pTrashed = await fileStore.writeEdited(documentId: 'trashed-doc', pageId: 'pt', bytes: [20]);

    await docRepo.createWithPages(id: 'active-doc', name: 'Active', pages: [NewPage(id: 'pa', originalPath: pActive)]);
    await docRepo.createWithPages(id: 'trashed-doc', name: 'Trashed', pages: [NewPage(id: 'pt', originalPath: pTrashed)]);
    await docRepo.moveToTrash('trashed-doc');

    // Create orphan directory with a file but no DB row
    final orphanRel = await fileStore.writeEdited(documentId: 'orphan-123', pageId: 'po', bytes: [99]);
    expect(await fileStore.resolve(orphanRel).exists(), isTrue);
    expect(await fileStore.listDocumentDirIds(), containsAll(['active-doc', 'trashed-doc', 'orphan-123']));

    final cleaned = await trashService.cleanOrphanDirectories();
    expect(cleaned, 1);

    expect(await fileStore.resolve(orphanRel).exists(), isFalse);
    expect(await fileStore.resolve(pActive).exists(), isTrue);
    expect(await fileStore.resolve(pTrashed).exists(), isTrue);
    expect(await fileStore.listDocumentDirIds(), containsAll(['active-doc', 'trashed-doc']));
    expect(await fileStore.listDocumentDirIds(), isNot(contains('orphan-123')));
  });
}
