import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:docloom/core/db/app_database.dart';
import 'package:docloom/core/db/schema.dart';
import 'package:docloom/features/scan/data/sqlite_signature_repository.dart';
import 'package:docloom/features/scan/domain/signature.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  late Directory tempDir;
  late String dbPath;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('schema_v3_test_');
    dbPath = p.join(tempDir.path, 'test_migration_v3.db');
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  test('a v2 database upgrades to v3 adding signatures table and repo CRUD works', () async {
    final v2Db = await databaseFactoryFfi.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 2,
        onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON;'),
        onCreate: (db, _) async {
          for (final sql in AppDatabaseSchema.v2) {
            await db.execute(sql);
          }
        },
      ),
    );

    final now = DateTime.now().toUtc();
    await v2Db.insert('folders', {
      'id': 'folder-1',
      'name': 'Work',
      'color_index': 1,
      'created_at': now.millisecondsSinceEpoch,
      'updated_at': now.millisecondsSinceEpoch,
    });
    await v2Db.close();

    // Reopen using AppDatabase which migrates to v3
    final appDb = await AppDatabase.open(
      factory: databaseFactoryFfi,
      path: dbPath,
    );

    // Verify v2 folder is preserved
    final folders = await appDb.db.query('folders');
    expect(folders.length, equals(1));
    expect(folders.first['name'], equals('Work'));

    // Verify SqliteSignatureRepository CRUD
    final repo = SqliteSignatureRepository(appDb);
    expect(await repo.list(), isEmpty);

    final sig1 = Signature(
      id: 'sig-1',
      path: '/path/to/sig1.png',
      createdAt: now.millisecondsSinceEpoch,
    );
    await repo.add(sig1);

    final list = await repo.list();
    expect(list.length, equals(1));
    expect(list.first.id, equals('sig-1'));
    expect(list.first.path, equals('/path/to/sig1.png'));

    await repo.delete('sig-1');
    expect(await repo.list(), isEmpty);

    await appDb.close();
  });
}
