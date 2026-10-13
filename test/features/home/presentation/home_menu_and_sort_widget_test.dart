import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:docloom/core/db/app_database.dart';
import 'package:docloom/core/providers/app_providers.dart';
import 'package:docloom/core/storage/document_file_store.dart';
import 'package:docloom/features/documents/data/sqlite_document_repository.dart';
import 'package:docloom/features/documents/domain/new_page.dart';
import 'package:docloom/features/folders/data/sqlite_folder_repository.dart';
import 'package:docloom/features/folders/presentation/folder_screen.dart';
import 'package:docloom/features/home/presentation/home_screen.dart';
import 'package:docloom/features/home/presentation/widgets/document_grid_tile.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  late AppDatabase db;
  late Directory tempDir;
  late DocumentFileStore fileStore;

  setUp(() async {
    db = await AppDatabase.open(factory: databaseFactoryFfi, path: inMemoryDatabasePath);
    tempDir = await Directory.systemTemp.createTemp('home_menu_test_');
    fileStore = DocumentFileStore(tempDir);
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  Widget buildApp(Widget child) => ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          fileStoreProvider.overrideWithValue(fileStore),
        ],
        child: MaterialApp(home: child),
      );

  Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildApp(screen));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pumpAndSettle();
  }

  testWidgets('Overflow menu on Home has ONLY 4 items: Sort By, Select, Create Folder, View Mode', (tester) async {
    final docRepo = SqliteDocumentRepository(db);
    await tester.runAsync(() => docRepo.createWithPages(id: 'd1', name: 'Doc 1', pages: const [NewPage(id: 'p1', originalPath: 'p1')]));

    await pumpScreen(tester, const HomeScreen());

    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();

    expect(find.text('Sort By'), findsOneWidget);
    expect(find.text('Select'), findsOneWidget);
    expect(find.text('Create Folder'), findsOneWidget);
    expect(find.text('View Mode'), findsOneWidget);
    expect(find.text('Import'), findsNothing);
    expect(find.text('PDF Tools'), findsNothing);
    expect(find.text('Sync Now'), findsNothing);
  });

  testWidgets('Overflow menu on FolderScreen has ONLY 3 items: Sort By, Select, View Mode', (tester) async {
    final folderRepo = SqliteFolderRepository(db);
    final docRepo = SqliteDocumentRepository(db);
    late String folderId;
    await tester.runAsync(() async {
      final f = await folderRepo.create(name: 'Work');
      folderId = f.id;
      await docRepo.createWithPages(id: 'd1', name: 'Work Doc', folderId: f.id, pages: const [NewPage(id: 'p1', originalPath: 'p1')]);
    });

    await pumpScreen(tester, FolderScreen(folderId: folderId));

    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();

    expect(find.text('Sort By'), findsOneWidget);
    expect(find.text('Select'), findsOneWidget);
    expect(find.text('Create Folder'), findsNothing);
    expect(find.text('View Mode'), findsOneWidget);
  });

  testWidgets('Sort By dialog changes sort order and View Mode toggles grid', (tester) async {
    final docRepo = SqliteDocumentRepository(db);
    await tester.runAsync(() async {
      await docRepo.createWithPages(id: 'd1', name: 'Beta Doc', pages: const [NewPage(id: 'p1', originalPath: 'p1')]);
      await docRepo.createWithPages(id: 'd2', name: 'Alpha Doc', pages: const [NewPage(id: 'p2', originalPath: 'p2')]);
    });

    await pumpScreen(tester, const HomeScreen());

    // Open menu and tap Sort By
    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sort By'));
    await tester.pumpAndSettle();

    expect(find.text('Sort by'), findsOneWidget);
    expect(find.text('Name (A-Z)'), findsOneWidget);

    // Select Name (A-Z)
    await tester.tap(find.text('Name (A-Z)'));
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pumpAndSettle();

    // Toggle View Mode to Grid
    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View Mode'));
    await tester.pumpAndSettle();

    expect(find.byType(DocumentGridTile), findsNWidgets(2));
  });
}
