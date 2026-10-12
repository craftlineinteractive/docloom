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
  setUpAll(sqfliteFfiInit);

  late AppDatabase db;
  late Directory tempDir;
  late DocumentFileStore fileStore;

  setUp(() async {
    db = await AppDatabase.open(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    tempDir = await Directory.systemTemp.createTemp('db_check_empty_test_');
    fileStore = DocumentFileStore(tempDir);
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        fileStoreProvider.overrideWithValue(fileStore),
      ],
      child: const MaterialApp(home: DbCheckScreen()),
    );
  }

  testWidgets('DbCheckScreen logs informative messages when actions have nothing to do', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.runAsync(() async {
      await tester.pumpWidget(buildTestWidget());
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();

    // 1. Trash when no documents exist
    await tester.runAsync(() async {
      await tester.tap(find.text('Trash Newest Root Doc'));
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();
    expect(find.textContaining('No root documents to trash'), findsOneWidget);

    // 2. Restore when no trashed documents exist
    await tester.runAsync(() async {
      await tester.tap(find.text('Restore Newest Trashed Doc'));
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();
    expect(find.textContaining('No trashed documents to restore'), findsOneWidget);

    // 3. Empty trash when trash is already empty
    await tester.runAsync(() async {
      await tester.tap(find.text('Empty Trash'));
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();
    expect(find.textContaining('Trash is already empty'), findsOneWidget);
  });
}
