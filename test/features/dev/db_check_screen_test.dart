import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:docloom/core/db/app_database.dart';
import 'package:docloom/core/providers/app_providers.dart';
import 'package:docloom/core/storage/document_file_store.dart';
import 'package:docloom/features/dev/db_check_screen.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  late AppDatabase db;
  late Directory tempDir;
  late DocumentFileStore fileStore;

  setUp(() async {
    db = await AppDatabase.open(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    tempDir = await Directory.systemTemp.createTemp('db_check_screen_test_');
    fileStore = DocumentFileStore(tempDir);
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        fileStoreProvider.overrideWithValue(fileStore),
      ],
      child: const MaterialApp(
        home: DbCheckScreen(),
      ),
    );
  }

  testWidgets('DbCheckScreen creates folder and document, trashes, restores, and empties trash', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.runAsync(() async {
      await tester.pumpWidget(buildTestWidget());
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();

    expect(find.text('Live Counts'), findsOneWidget);
    expect(find.text('Active Folders'), findsOneWidget);
    expect(find.text('0'), findsNWidgets(4));

    // 1. Create folder
    await tester.runAsync(() async {
      await tester.tap(find.text('Create Folder'));
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
    await tester.pump();

    expect(find.text('Active Folders'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);

    // 2. Create document with 2 pages
    await tester.runAsync(() async {
      await tester.tap(find.text('Create Document (2 Pages)'));
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
    await tester.pump();

    expect(find.text('Root Documents'), findsOneWidget);
    expect(find.text('Files on Disk'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);

    // 3. Trash document
    await tester.runAsync(() async {
      await tester.tap(find.text('Trash Newest Root Doc'));
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
    await tester.pump();

    expect(find.text('Trashed Documents'), findsOneWidget);

    // 4. Restore document
    await tester.runAsync(() async {
      await tester.tap(find.text('Restore Newest Trashed Doc'));
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
    await tester.pump();

    // 5. Trash again and empty
    await tester.runAsync(() async {
      await tester.tap(find.text('Trash Newest Root Doc'));
      await Future<void>.delayed(const Duration(milliseconds: 1000));
    });
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      await tester.ensureVisible(find.text('Empty Trash'));
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await tester.tap(find.text('Empty Trash'));
      await Future<void>.delayed(const Duration(milliseconds: 1200));
    });
    await tester.pumpAndSettle();
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(find.textContaining('Action Results'), findsOneWidget);
    expect(find.textContaining('Emptied trash'), findsOneWidget);
  });
}
