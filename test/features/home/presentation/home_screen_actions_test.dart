import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:docloom/core/db/app_database.dart';
import 'package:docloom/core/providers/app_providers.dart';
import 'package:docloom/core/providers/home_providers.dart';
import 'package:docloom/core/storage/document_file_store.dart';
import 'package:docloom/core/widgets/widgets.dart';
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
    tempDir = await Directory.systemTemp.createTemp('home_actions_test_');
    fileStore = DocumentFileStore(tempDir);
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  testWidgets('Plus button on FabPill opens sheet with 3 rows and dismisses on tap', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          fileStoreProvider.overrideWithValue(fileStore),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(LucideIcons.plus));
    await tester.pumpAndSettle();

    expect(find.text('Add Document'), findsOneWidget);
    expect(find.text('From Gallery'), findsOneWidget);
    expect(find.text('PDF as Image'), findsOneWidget);
    expect(find.text('Import Documents'), findsOneWidget);

    await tester.tap(find.text('From Gallery'));
    await tester.pumpAndSettle();

    expect(find.text('Add Document'), findsNothing);
  });

  testWidgets('Document with missing cover file renders placeholder without exception', (tester) async {
    final docRepo = SqliteDocumentRepository(db);
    await tester.runAsync(() async {
      await docRepo.createWithPages(
        id: 'd-missing-file',
        name: 'Doc With Missing File',
        pages: const [NewPage(id: 'p-miss', originalPath: 'documents/d-missing-file/p-miss_original.jpg')],
      );
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          fileStoreProvider.overrideWithValue(fileStore),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Doc With Missing File'), findsOneWidget);
    expect(find.byIcon(LucideIcons.fileText), findsWidgets);
  });

  testWidgets('Error state shows Try again action and recovers upon retry', (tester) async {
    var shouldFail = true;
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        fileStoreProvider.overrideWithValue(fileStore),
        foldersProvider.overrideWith((ref) async {
          if (shouldFail) throw Exception('Simulated load error');
          return const [];
        }),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pumpAndSettle();

    expect(find.text('Failed to load'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);

    shouldFail = false;
    await tester.tap(find.text('Try again'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pumpAndSettle();

    expect(find.text('Failed to load'), findsNothing);
    expect(find.text('Scan your first document'), findsOneWidget);
    expect(find.byType(FabPill), findsOneWidget);
  });
}
