import 'package:sqflite/sqflite.dart';
import 'schema.dart';

class AppDatabase {
  const AppDatabase(this.db);

  final Database db;

  static const version = 3;

  static Future<AppDatabase> open({
    required DatabaseFactory factory,
    required String path,
  }) async {
    final database = await factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: version,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON;');
        },
        onCreate: (db, version) async {
          for (final statement in AppDatabaseSchema.v3) {
            await db.execute(statement);
          }
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await db.execute('ALTER TABLE pages ADD COLUMN crop_json TEXT;');
          }
          if (oldVersion < 3) {
            await db.execute('''
              CREATE TABLE IF NOT EXISTS signatures (
                id TEXT PRIMARY KEY,
                path TEXT NOT NULL,
                created_at INTEGER NOT NULL
              );
            ''');
            await db.execute(
              'CREATE INDEX IF NOT EXISTS idx_signatures_created ON signatures(created_at);',
            );
          }
        },
      ),
    );
    return AppDatabase(database);
  }

  Future<void> close() => db.close();
}
