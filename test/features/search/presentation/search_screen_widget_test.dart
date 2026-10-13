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
import 'package:docloom/features/search/presentation/search_screen.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  late AppDatabase db;
  late Directory tempDir;
  late DocumentFileStore fileStore;

  setUp(() async {
    db = await AppDatabase.open(factory: databaseFactoryFfi, path: inMemoryDatabasePath);
    tempDir = await Directory.systemTemp.createTemp('search_test_');
    fileStore = DocumentFileStore(tempDir);
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  Widget buildApp() => ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          fileStoreProvider.overrideWithValue(fileStore),
        ],
        child: const MaterialApp(home: SearchScreen()),
      );

  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildApp());
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('SearchScreen shows initial hint and displays results with folder name on query', (tester) async {
    final folderRepo = SqliteFolderRepository(db);
    final docRepo = SqliteDocumentRepository(db);
    await tester.runAsync(() async {
      final f = await folderRepo.create(name: 'Taxes');
      await docRepo.createWithPages(id: 'd1', name: 'Receipt 2026', folderId: f.id, pages: const [NewPage(id: 'p1', originalPath: 'p1')]);
      await docRepo.createWithPages(id: 'd2', name: 'Passport Scan', pages: const [NewPage(id: 'p2', originalPath: 'p2')]);
    });

    await pumpScreen(tester);

    // Initial state shows search hint
    expect(find.text('Search documents'), findsOneWidget);

    // Enter query
    await tester.enterText(find.byType(TextField), 'Receipt');
    // Advance fake timer by 300ms to trigger debounce
    await tester.pump(const Duration(milliseconds: 300));
    // Allow native FFI database call to finish
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pump();

    expect(find.text('Receipt 2026'), findsOneWidget);
    expect(find.text('Taxes'), findsOneWidget);
    expect(find.text('Passport Scan'), findsNothing);

    // Tap result -> shows toast
    await tester.tap(find.text('Receipt 2026'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Viewer comes in a later phase'), findsOneWidget);

    // Enter non-matching query
    await tester.enterText(find.byType(TextField), 'NonexistentDoc');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pump();

    expect(find.text('No documents found'), findsOneWidget);
  });
}
