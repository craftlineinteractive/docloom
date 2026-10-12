import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:docloom/core/db/app_database.dart';
import 'package:docloom/core/storage/document_file_store.dart';
import 'package:docloom/features/dev/seed_data.dart';
import 'package:docloom/features/documents/data/sqlite_document_repository.dart';
import 'package:docloom/features/folders/data/sqlite_folder_repository.dart';
import 'package:docloom/features/trash/application/trash_service.dart';
import 'package:docloom/features/trash/data/sqlite_trash_repository.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  late AppDatabase db;
  late Directory tempDir;
  late DocumentFileStore fileStore;
  late SqliteFolderRepository folderRepo;
  late SqliteDocumentRepository docRepo;
  late SqliteTrashRepository trashRepo;
  late TrashService trashService;

  setUp(() async {
    db = await AppDatabase.open(factory: databaseFactoryFfi, path: inMemoryDatabasePath);
    tempDir = await Directory.systemTemp.createTemp('seed_data_test_');
    fileStore = DocumentFileStore(tempDir);
    folderRepo = SqliteFolderRepository(db);
    docRepo = SqliteDocumentRepository(db);
    trashRepo = SqliteTrashRepository(db);
    trashService = TrashService(trashRepo, docRepo, fileStore);
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  test('seedSampleData creates correct folder and doc counts with decodable cover images', () async {
    final result = await seedSampleData(
      folderRepo: folderRepo,
      docRepo: docRepo,
      trashService: trashService,
      fileStore: fileStore,
    );

    expect(result.foldersCount, 3);
    expect(result.docsCount, 12);
    expect(result.trashedCount, 1);

    final folders = await folderRepo.listActive();
    expect(folders.length, 3);

    final rootDocs = await docRepo.listInFolder();
    expect(rootDocs.length, 6);

    for (final folder in folders) {
      final insideDocs = await docRepo.listInFolder(folderId: folder.folder.id);
      expect(insideDocs.length, 2);
    }

    final trashedDocs = await trashRepo.listTrashedDocuments();
    expect(trashedDocs.length, 1);

    // Verify every root doc cover file exists and decodes as 600x800 image
    for (final summary in rootDocs) {
      expect(summary.coverPath, isNotNull);
      final coverFile = fileStore.resolve(summary.coverPath!);
      expect(await coverFile.exists(), isTrue);

      final bytes = await coverFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      expect(frame.image.width, 600);
      expect(frame.image.height, 800);
    }

    // Verify clearAllData cleans everything
    await clearAllData(folderRepo: folderRepo, docRepo: docRepo, trashService: trashService);
    expect(await folderRepo.listActive(), isEmpty);
    expect(await docRepo.listInFolder(), isEmpty);
    expect(await trashRepo.listTrashedDocuments(), isEmpty);
    expect(await fileStore.countFiles(), 0);
  });
}
