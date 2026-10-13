import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:docloom/core/db/app_database.dart';
import 'package:docloom/core/providers/app_providers.dart';
import 'package:docloom/core/providers/home_providers.dart';
import 'package:docloom/core/storage/document_file_store.dart';
import 'package:docloom/features/documents/data/sqlite_document_repository.dart';
import 'package:docloom/features/documents/domain/new_page.dart';
import 'package:docloom/features/folders/data/sqlite_folder_repository.dart';
import 'package:docloom/features/folders/presentation/folder_screen.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  late AppDatabase db;
  late Directory tempDir;
  late DocumentFileStore fileStore;

  setUp(() async {
    db = await AppDatabase.open(factory: databaseFactoryFfi, path: inMemoryDatabasePath);
    tempDir = await Directory.systemTemp.createTemp('folder_screen_test_');
    fileStore = DocumentFileStore(tempDir);
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  Widget buildScreen(String folderId) {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        fileStoreProvider.overrideWithValue(fileStore),
      ],
      child: MaterialApp(home: FolderScreen(folderId: folderId)),
    );
  }

  Future<void> pumpScreen(WidgetTester tester, String folderId) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildScreen(folderId));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pumpAndSettle();
  }

  testWidgets('FolderScreen lists only documents inside that folder', (tester) async {
    final folderRepo = SqliteFolderRepository(db);
    final docRepo = SqliteDocumentRepository(db);

    late String folderId;
    await tester.runAsync(() async {
      final f = await folderRepo.create(name: 'Work Folder');
      folderId = f.id;
      await docRepo.createWithPages(id: 'd-in', name: 'Work Doc', folderId: f.id, pages: const [NewPage(id: 'p1', originalPath: 'p1')]);
      await docRepo.createWithPages(id: 'd-root', name: 'Root Doc', pages: const [NewPage(id: 'p2', originalPath: 'p2')]);
    });

    await pumpScreen(tester, folderId);

    expect(find.text('Work Folder'), findsOneWidget);
    expect(find.text('Work Doc'), findsOneWidget);
    expect(find.text('Root Doc'), findsNothing);
  });

  testWidgets('FolderScreen shows unavailable state when folder is trashed underneath it', (tester) async {
    final folderRepo = SqliteFolderRepository(db);
    late String folderId;
    await tester.runAsync(() async {
      final f = await folderRepo.create(name: 'Will Be Trashed');
      folderId = f.id;
    });

    await pumpScreen(tester, folderId);
    expect(find.text('Will Be Trashed'), findsOneWidget);

    // Trash the folder underneath
    await tester.runAsync(() async {
      await folderRepo.moveToTrash(folderId);
    });

    // Invalidate/refresh provider
    final element = tester.element(find.byType(FolderScreen));
    ProviderScope.containerOf(element).refreshLibrary();

    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pumpAndSettle();

    expect(find.text('This folder is no longer available'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
  });
}
