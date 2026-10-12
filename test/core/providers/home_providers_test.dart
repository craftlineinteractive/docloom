import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:docloom/core/db/app_database.dart';
import 'package:docloom/core/providers/app_providers.dart';
import 'package:docloom/core/providers/home_providers.dart';
import 'package:docloom/core/storage/document_file_store.dart';
import 'package:docloom/features/documents/domain/document_sort.dart';
import 'package:docloom/features/documents/domain/new_page.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  late AppDatabase db;
  late Directory tempDir;
  late DocumentFileStore fileStore;
  late ProviderContainer container;

  setUp(() async {
    db = await AppDatabase.open(factory: databaseFactoryFfi, path: inMemoryDatabasePath);
    tempDir = await Directory.systemTemp.createTemp('home_providers_test_');
    fileStore = DocumentFileStore(tempDir);
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        fileStoreProvider.overrideWithValue(fileStore),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  test('documentsProvider partitions by folderId and respects documentSortProvider', () async {
    final folderRepo = container.read(folderRepositoryProvider);
    final docRepo = container.read(documentRepositoryProvider);

    final folder = await folderRepo.create(name: 'Work');
    await docRepo.createWithPages(id: 'root-z', name: 'Zebra', pages: const [NewPage(id: 'p1', originalPath: 'p1')]);
    await docRepo.createWithPages(id: 'root-a', name: 'Apple', pages: const [NewPage(id: 'p2', originalPath: 'p2')]);
    await docRepo.createWithPages(id: 'folder-doc', name: 'Task', folderId: folder.id, pages: const [NewPage(id: 'p3', originalPath: 'p3')]);

    final rootDocs = await container.read(documentsProvider(null).future);
    expect(rootDocs.map((d) => d.document.id).toSet(), equals({'root-z', 'root-a'}));

    final folderDocs = await container.read(documentsProvider(folder.id).future);
    expect(folderDocs.map((d) => d.document.id).toList(), equals(['folder-doc']));

    // Change sort to nameAsc
    container.read(documentSortProvider.notifier).setSort(DocumentSort.nameAsc);
    final sortedRoots = await container.read(documentsProvider(null).future);
    expect(sortedRoots.map((d) => d.document.name).toList(), equals(['Apple', 'Zebra']));

    // foldersProvider and folderByIdProvider
    final activeFolders = await container.read(foldersProvider.future);
    expect(activeFolders.length, 1);
    expect(activeFolders.first.folder.name, 'Work');

    final fetchedFolder = await container.read(folderByIdProvider(folder.id).future);
    expect(fetchedFolder?.name, 'Work');
  });

  test('refreshLibrary invalidates and makes newly created document appear', () async {
    final docRepo = container.read(documentRepositoryProvider);
    final initialDocs = await container.read(documentsProvider(null).future);
    expect(initialDocs, isEmpty);

    await docRepo.createWithPages(id: 'new-doc', name: 'New Doc', pages: const [NewPage(id: 'p', originalPath: 'p')]);

    // Invalidate via extension
    container.refreshLibrary();

    final updatedDocs = await container.read(documentsProvider(null).future);
    expect(updatedDocs.length, 1);
    expect(updatedDocs.first.document.name, 'New Doc');
  });
}
