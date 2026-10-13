import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:docloom/app/router/app_router.dart';
import 'package:docloom/core/db/app_database.dart';
import 'package:docloom/core/providers/app_providers.dart';
import 'package:docloom/core/providers/home_providers.dart';
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
    tempDir = await Directory.systemTemp.createTemp('select_nav_test_');
    fileStore = DocumentFileStore(tempDir);
    appRouter.go('/');
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
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pumpAndSettle();
  }

  testWidgets('select mode is cleared when navigating from Home into a folder', (tester) async {
    final folderRepo = SqliteFolderRepository(db);
    final docRepo = SqliteDocumentRepository(db);

    await tester.runAsync(() async {
      await folderRepo.create(name: 'Projects');
      await docRepo.createWithPages(id: 'd1', name: 'Root Doc', pages: const [NewPage(id: 'p1', originalPath: 'p1')]);
    });

    await pumpApp(tester);

    // Enter select mode on Home
    await tester.longPress(find.text('Root Doc'));
    await tester.pumpAndSettle();
    expect(find.text('1 selected'), findsOneWidget);

    // Tap into folder
    await tester.tap(find.text('Projects'));
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pumpAndSettle();

    // Verify folder screen is opened and select mode is cleared
    expect(find.text('Projects'), findsOneWidget);
    expect(find.text('1 selected'), findsNothing);
    final element = tester.element(find.text('Projects').first);
    final container = ProviderScope.containerOf(element);
    expect(container.read(selectModeProvider), isFalse);
    expect(container.read(selectionProvider), isEmpty);
  });

  testWidgets('select mode is cleared when leaving the folder screen', (tester) async {
    final folderRepo = SqliteFolderRepository(db);
    final docRepo = SqliteDocumentRepository(db);

    late String folderId;
    await tester.runAsync(() async {
      final f = await folderRepo.create(name: 'Archive');
      folderId = f.id;
      await docRepo.createWithPages(id: 'd2', name: 'Inner Doc', folderId: folderId, pages: const [NewPage(id: 'p2', originalPath: 'p2')]);
    });

    await pumpApp(tester);

    // Navigate to folder
    await tester.tap(find.text('Archive'));
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pumpAndSettle();
    expect(find.text('Inner Doc'), findsOneWidget);

    // Enter select mode inside folder
    await tester.longPress(find.text('Inner Doc'));
    await tester.pumpAndSettle();
    expect(find.text('1 selected'), findsOneWidget);

    // Tap Cancel in selection app bar
    await tester.tap(find.byTooltip('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('1 selected'), findsNothing);

    // Tap Back to leave folder screen
    await tester.tap(find.byTooltip('Back'));
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pumpAndSettle();

    // Check we are back on Home and select mode is cleared
    expect(find.text('docLoom'), findsOneWidget);
    expect(find.text('1 selected'), findsNothing);
    final element = tester.element(find.text('docLoom'));
    final container = ProviderScope.containerOf(element);
    expect(container.read(selectModeProvider), isFalse);
    expect(container.read(selectionProvider), isEmpty);
  });
}
