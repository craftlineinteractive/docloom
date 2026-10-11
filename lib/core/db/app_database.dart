import 'package:sqflite/sqflite.dart';
import 'schema.dart';

class AppDatabase {
  const AppDatabase(this.db);

  final Database db;

  static const version = 1;

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
          for (final statement in AppDatabaseSchema.v1) {
            await db.execute(statement);
          }
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          // Future schema migrations will be placed here (e.g. if oldVersion < 2).
          throw UnsupportedError(
            'Migration from version $oldVersion to $newVersion is not supported.',
          );
        },
      ),
    );
    return AppDatabase(database);
  }

  Future<void> close() => db.close();
}
