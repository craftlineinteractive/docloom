import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:docloom/core/db/app_database.dart';
import 'package:docloom/core/db/schema.dart';
import 'package:docloom/features/documents/data/sqlite_document_repository.dart';
import 'package:docloom/features/documents/domain/new_page.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  late Directory tempDir;
  late String dbPath;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('schema_v2_test_');
    dbPath = p.join(tempDir.path, 'test_migration.db');
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  test('a v1 database with rows upgrades to v2 with no data loss and new columns round-trip', () async {
    // 1. Create a v1 database with rows
    final v1Db = await databaseFactoryFfi.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON;'),
        onCreate: (db, _) async {
          for (final sql in AppDatabaseSchema.v1) {
            await db.execute(sql);
          }
        },
      ),
    );

    final now = DateTime.now().toUtc();
    await v1Db.insert('folders', {
      'id': 'folder-1',
      'name': 'Work',
      'color_index': 1,
      'created_at': now.millisecondsSinceEpoch,
      'updated_at': now.millisecondsSinceEpoch,
    });

    await v1Db.insert('documents', {
      'id': 'doc-1',
      'folder_id': 'folder-1',
      'name': 'Contract',
      'is_favorite': 0,
      'created_at': now.millisecondsSinceEpoch,
      'updated_at': now.millisecondsSinceEpoch,
    });

    await v1Db.insert('pages', {
      'id': 'page-1',
      'document_id': 'doc-1',
      'position': 0,
      'original_path': 'documents/doc-1/p1_original.jpg',
      'edited_path': 'documents/doc-1/p1_edited.jpg',
      'filter_id': 'grayscale',
      'rotation': 90,
      'created_at': now.millisecondsSinceEpoch,
    });

    await v1Db.close();

    // 2. Open via AppDatabase.open (migrates 1 -> 2)
    final appDb = await AppDatabase.open(
      factory: databaseFactoryFfi,
      path: dbPath,
    );

    final repo = SqliteDocumentRepository(appDb);

    // Verify existing v1 data preserved
    final doc = await repo.getById('doc-1');
    expect(doc, isNotNull);
    expect(doc!.name, equals('Contract'));

    final pagesV1 = await repo.getPages('doc-1');
    expect(pagesV1.length, equals(1));
    expect(pagesV1.first.id, equals('page-1'));
    expect(pagesV1.first.cropJson, isNull);
    expect(pagesV1.first.rotation, equals(90));
    expect(pagesV1.first.filterId, equals('grayscale'));

    // 3. Round-trip new columns including cropJson on v2
    const testCropJson = '{"tl":[0.1,0.1],"tr":[0.9,0.1],"br":[0.9,0.9],"bl":[0.1,0.9]}';
    await repo.createWithPages(
      id: 'doc-2',
      name: 'Receipt',
      pages: [
        const NewPage(
          id: 'page-2a',
          originalPath: 'documents/doc-2/p2a_original.jpg',
          editedPath: 'documents/doc-2/p2a_edited.jpg',
          filterId: 'vivid_light',
          rotation: 180,
          cropJson: testCropJson,
        ),
      ],
    );

    final pagesV2 = await repo.getPages('doc-2');
    expect(pagesV2.length, equals(1));
    final p2 = pagesV2.first;
    expect(p2.id, equals('page-2a'));
    expect(p2.originalPath, equals('documents/doc-2/p2a_original.jpg'));
    expect(p2.editedPath, equals('documents/doc-2/p2a_edited.jpg'));
    expect(p2.filterId, equals('vivid_light'));
    expect(p2.rotation, equals(180));
    expect(p2.cropJson, equals(testCropJson));

    await appDb.close();
  });
}
