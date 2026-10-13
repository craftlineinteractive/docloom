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
import 'package:docloom/features/home/presentation/home_screen.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  late AppDatabase db;
  late Directory tempDir;
  late DocumentFileStore fileStore;

  setUp(() async {
    db = await AppDatabase.open(factory: databaseFactoryFfi, path: inMemoryDatabasePath);
    tempDir = await Directory.systemTemp.createTemp('select_mode_test_');
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
        child: const MaterialApp(home: HomeScreen()),
      );

  Future<void> pumpHome(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildApp());
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pumpAndSettle();
  }

  testWidgets('Long press enters select mode, Select All works, and X exits', (tester) async {
    final docRepo = SqliteDocumentRepository(db);
    await tester.runAsync(() async {
      await docRepo.createWithPages(id: 'd1', name: 'Doc 1', pages: const [NewPage(id: 'p1', originalPath: 'p1')]);
      await docRepo.createWithPages(id: 'd2', name: 'Doc 2', pages: const [NewPage(id: 'p2', originalPath: 'p2')]);
    });

    await pumpHome(tester);

    // Long press on Doc 1
    await tester.longPress(find.text('Doc 1'));
    await tester.pumpAndSettle();

    expect(find.text('1 selected'), findsOneWidget);
    expect(find.text('Move'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);

    // Select all
    await tester.tap(find.byTooltip('Select all'));
    await tester.pumpAndSettle();
    expect(find.text('2 selected'), findsOneWidget);

    // Cancel via X button
    await tester.tap(find.byTooltip('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('docLoom'), findsOneWidget);
    expect(find.text('2 selected'), findsNothing);
  });

  testWidgets('Batch delete removes documents, shows toast with Undo, and Undo restores', (tester) async {
    final docRepo = SqliteDocumentRepository(db);
    await tester.runAsync(() async {
      await docRepo.createWithPages(id: 'd1', name: 'Doc 1', pages: const [NewPage(id: 'p1', originalPath: 'p1')]);
      await docRepo.createWithPages(id: 'd2', name: 'Doc 2', pages: const [NewPage(id: 'p2', originalPath: 'p2')]);
    });

    await pumpHome(tester);

    // Enter select mode from menu
    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Select'));
    await tester.pumpAndSettle();

    expect(find.text('0 selected'), findsOneWidget);

    // Tap both cards
    await tester.tap(find.text('Doc 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Doc 2'));
    await tester.pumpAndSettle();
    expect(find.text('2 selected'), findsOneWidget);

    // Tap Delete
    await tester.tap(find.text('Delete'));
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pumpAndSettle();

    expect(find.text('2 documents moved to Trash'), findsOneWidget);
    expect(find.text('Doc 1'), findsNothing);
    expect(find.text('Doc 2'), findsNothing);

    // Tap Undo
    await tester.tap(find.text('Undo'));
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pumpAndSettle();

    expect(find.text('Doc 1'), findsOneWidget);
    expect(find.text('Doc 2'), findsOneWidget);
  });
}
