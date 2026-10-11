import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:docloom/core/db/app_database.dart';
import 'package:docloom/core/providers/app_providers.dart';
import 'package:docloom/core/storage/document_file_store.dart';
import 'package:docloom/features/documents/domain/document_repository.dart';
import 'package:docloom/features/folders/domain/folder_repository.dart';
import 'package:docloom/features/trash/application/trash_service.dart';
import 'package:docloom/features/trash/domain/trash_repository.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  test('default appDatabaseProvider and fileStoreProvider throw UnimplementedError', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      () => container.read(appDatabaseProvider),
      throwsA(predicate((e) => e.toString().contains('override in main'))),
    );
    expect(
      () => container.read(fileStoreProvider),
      throwsA(predicate((e) => e.toString().contains('override in main'))),
    );
  });

  test('reading providers with overrides returns correct instance types', () async {
    final db = await AppDatabase.open(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    final tempDir = await Directory.systemTemp.createTemp('providers_test_');
    final fileStore = DocumentFileStore(tempDir);

    final List<Override> overrides = [
      appDatabaseProvider.overrideWithValue(db),
      fileStoreProvider.overrideWithValue(fileStore),
    ];

    final container = ProviderContainer(overrides: overrides);

    addTearDown(() async {
      container.dispose();
      await db.close();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    expect(container.read(folderRepositoryProvider), isA<FolderRepository>());
    expect(container.read(documentRepositoryProvider), isA<DocumentRepository>());
    expect(container.read(trashRepositoryProvider), isA<TrashRepository>());
    expect(container.read(trashServiceProvider), isA<TrashService>());
    expect(container.read(clockProvider)(), isA<DateTime>());
    expect(container.read(idGeneratorProvider)(), isA<String>());
  });
}
