import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:docloom/app/router/app_router.dart';
import 'package:docloom/core/db/app_database.dart';
import 'package:docloom/core/providers/app_providers.dart';
import 'package:docloom/core/storage/document_file_store.dart';
import 'package:docloom/features/documents/data/sqlite_document_repository.dart';
import 'package:docloom/features/documents/domain/new_page.dart';
import 'package:docloom/features/folders/data/sqlite_folder_repository.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  late AppDatabase db;
  late Directory tempDir;
  late DocumentFileStore fileStore;

  setUp(() async {
    db = await AppDatabase.open(factory: databaseFactoryFfi, path: inMemoryDatabasePath);
    tempDir = await Directory.systemTemp.createTemp('doc_crud_test_');
    fileStore = DocumentFileStore(tempDir);
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  Widget buildApp() {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        fileStoreProvider.overrideWithValue(fileStore),
      ],
      child: MaterialApp.router(routerConfig: appRouter),
    );
  }

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildApp());
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pumpAndSettle();
  }

  testWidgets('document delete then Undo restores the document on Home', (tester) async {
    final docRepo = SqliteDocumentRepository(db);
    await tester.runAsync(() => docRepo.createWithPages(
          id: 'doc-to-del',
          name: 'Doc To Delete',
          pages: const [NewPage(id: 'p1', originalPath: 'p1')],
        ));

    await pumpApp(tester);
    expect(find.text('Doc To Delete'), findsOneWidget);

    // Tap options button on document card
    await tester.tap(find.byTooltip('Document options'));
    await tester.pumpAndSettle();

    // Tap Delete
    await tester.tap(find.text('Delete'));
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pumpAndSettle();

    expect(find.text('Doc To Delete'), findsNothing);
    expect(find.text('Moved to Trash'), findsOneWidget);

    // Tap Undo
    await tester.tap(find.text('Undo'));
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pumpAndSettle();

    expect(find.text('Doc To Delete'), findsOneWidget);
  });

  testWidgets('moving a document to a folder updates both Home and Folder screens', (tester) async {
    final folderRepo = SqliteFolderRepository(db);
    final docRepo = SqliteDocumentRepository(db);

    await tester.runAsync(() async {
      await folderRepo.create(name: 'Project Archive');
      await docRepo.createWithPages(
        id: 'doc-to-move',
        name: 'Report 2026',
        pages: const [NewPage(id: 'p2', originalPath: 'p2')],
      );
    });

    await pumpApp(tester);
    expect(find.text('Report 2026'), findsOneWidget);

    // Tap options -> Move to folder
    await tester.tap(find.byTooltip('Document options'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Move to folder'));
    await tester.pumpAndSettle();

    // Select Project Archive
    await tester.tap(find.text('Project Archive').last);
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pumpAndSettle();

    // Document is moved out of Home root documents
    expect(find.text('Report 2026'), findsNothing);

    // Navigate to Project Archive folder
    await tester.tap(find.text('Project Archive'));
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pumpAndSettle();

    // Document appears inside the folder
    expect(find.text('Report 2026'), findsOneWidget);
  });
}
