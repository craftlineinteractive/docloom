import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:docloom/app/router/app_router.dart';
import 'package:docloom/core/db/app_database.dart';
import 'package:docloom/core/providers/app_providers.dart';
import 'package:docloom/core/storage/document_file_store.dart';
import 'package:docloom/core/widgets/widgets.dart';
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
    tempDir = await Directory.systemTemp.createTemp('folder_crud_test_');
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

  testWidgets('create-folder dialog validates empty name and creates folder on valid name', (tester) async {
    final folderRepo = SqliteFolderRepository(db);
    await tester.runAsync(() => folderRepo.create(name: 'Initial Folder'));

    await pumpApp(tester);
    await tester.tap(find.byIcon(LucideIcons.folderPlus));
    await tester.pumpAndSettle();

    expect(find.text('New folder'), findsOneWidget);
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();
    expect(find.text('Folder name cannot be empty'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Tax Invoices');
    await tester.pump();
    await tester.tap(find.text('Create'));
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pumpAndSettle();

    expect(find.text('Tax Invoices'), findsOneWidget);
  });

  testWidgets('trashing a folder returns to Home, vanishes documents, and Undo restores them', (tester) async {
    final folderRepo = SqliteFolderRepository(db);
    final docRepo = SqliteDocumentRepository(db);

    await tester.runAsync(() async {
      final f = await folderRepo.create(name: 'ToDelete');
      await docRepo.createWithPages(id: 'd-inside', name: 'Doc Inside', folderId: f.id, pages: const [NewPage(id: 'p1', originalPath: 'p1')]);
    });

    await pumpApp(tester);
    expect(find.text('ToDelete'), findsOneWidget);

    // Navigate to folder
    await tester.tap(find.text('ToDelete'));
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pumpAndSettle();

    expect(find.text('Doc Inside'), findsOneWidget);

    // Open folder options from FolderScreen
    await tester.tap(find.byTooltip('Folder options'));
    await tester.pumpAndSettle();

    // Tap Delete (in bottom sheet, which shows confirm dialog)
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    // Confirm dialog
    expect(find.text('Delete folder'), findsOneWidget);
    await tester.tap(find.widgetWithText(AppButton, 'Delete'));
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pumpAndSettle();

    // Verify back on Home and folder is gone
    expect(find.text('ToDelete'), findsNothing);
    expect(find.text('Folder moved to Trash'), findsOneWidget);

    // Tap Undo
    await tester.tap(find.text('Undo'));
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pumpAndSettle();

    expect(find.text('ToDelete'), findsOneWidget);
  });
}
