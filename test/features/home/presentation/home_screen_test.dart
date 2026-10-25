import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:docloom/core/db/app_database.dart';
import 'package:docloom/core/providers/app_providers.dart';
import 'package:docloom/core/storage/document_file_store.dart';
import 'package:docloom/core/widgets/widgets.dart';
import 'package:docloom/features/documents/data/sqlite_document_repository.dart';
import 'package:docloom/features/documents/domain/new_page.dart';
import 'package:docloom/features/folders/data/sqlite_folder_repository.dart';
import 'package:docloom/features/home/presentation/home_screen.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  late AppDatabase db;
  late Directory tempDir;
  late DocumentFileStore fileStore;

  setUp(() async {
    db = await AppDatabase.open(factory: databaseFactoryFfi, path: inMemoryDatabasePath);
    tempDir = await Directory.systemTemp.createTemp('home_screen_test_');
    fileStore = DocumentFileStore(tempDir);
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  Widget buildScreen() {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        fileStoreProvider.overrideWithValue(fileStore),
      ],
      child: const MaterialApp(home: HomeScreen()),
    );
  }

  Future<void> pumpHomeScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildScreen());
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pumpAndSettle();
  }

  testWidgets('Empty database shows empty state matching mocups/home_empty without section headers', (tester) async {
    await pumpHomeScreen(tester);

    expect(find.text('Scan your first document'), findsOneWidget);
    expect(find.textContaining('Convert paper documents'), findsOneWidget);
    expect(find.text('Tap camera to scan'), findsOneWidget);
    expect(find.text('Tap + to import files'), findsOneWidget);
    expect(find.textContaining('Folders'), findsNothing);
    expect(find.textContaining('Documents'), findsNothing);
    expect(find.byType(FabPill), findsOneWidget);
  });

  testWidgets('With 3 folders and 4 documents, headers show counts and names appear', (tester) async {
    final folderRepo = SqliteFolderRepository(db);
    final docRepo = SqliteDocumentRepository(db);

    await tester.runAsync(() async {
      for (var i = 1; i <= 3; i++) {
        await folderRepo.create(name: 'Folder $i');
      }
      for (var i = 1; i <= 4; i++) {
        await docRepo.createWithPages(id: 'd$i', name: 'Doc $i', pages: [NewPage(id: 'p$i', originalPath: 'p$i.jpg')]);
      }
    });

    await pumpHomeScreen(tester);

    expect(find.text('Folders (3)'), findsOneWidget);
    expect(find.text('Documents (4)'), findsOneWidget);
    for (var i = 1; i <= 4; i++) {
      expect(find.text('Doc $i'), findsOneWidget);
    }
  });

  testWidgets('Trashed documents and documents in trashed folder do not appear', (tester) async {
    final folderRepo = SqliteFolderRepository(db);
    final docRepo = SqliteDocumentRepository(db);

    await tester.runAsync(() async {
      await folderRepo.create(name: 'Active Folder');
      final fTrash = await folderRepo.create(name: 'Trash Folder');
      await docRepo.createWithPages(id: 'doc-in-trash-folder', name: 'Hidden In Trashed Folder', folderId: fTrash.id, pages: const [NewPage(id: 'p1', originalPath: 'p1')]);
      await folderRepo.moveToTrash(fTrash.id);

      final dTrashed = await docRepo.createWithPages(id: 'doc-trashed', name: 'Hidden Trashed Doc', pages: const [NewPage(id: 'p2', originalPath: 'p2')]);
      await docRepo.moveToTrash(dTrashed.id);

      await docRepo.createWithPages(id: 'doc-visible', name: 'Visible Root Doc', pages: const [NewPage(id: 'p3', originalPath: 'p3')]);
    });

    await pumpHomeScreen(tester);

    expect(find.text('Hidden In Trashed Folder'), findsNothing);
    expect(find.text('Hidden Trashed Doc'), findsNothing);
    expect(find.text('Visible Root Doc'), findsOneWidget);
    expect(find.text('Trash Folder'), findsNothing);
    expect(find.text('Active Folder'), findsOneWidget);
  });

  testWidgets('Folders section header with create button remains visible when there are no folders', (tester) async {
    final docRepo = SqliteDocumentRepository(db);
    await tester.runAsync(() async {
      await docRepo.createWithPages(id: 'only-doc', name: 'Root Document Only', pages: const [NewPage(id: 'p', originalPath: 'p')]);
    });

    await pumpHomeScreen(tester);

    expect(find.textContaining('Folders'), findsOneWidget);
    expect(find.byTooltip('Create folder'), findsOneWidget);
    expect(find.text('Documents (1)'), findsOneWidget);
    expect(find.text('Root Document Only'), findsOneWidget);
  });
}
