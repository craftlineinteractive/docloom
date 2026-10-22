import 'package:sqflite/sqflite.dart';
import '../../../core/db/app_database.dart';
import '../domain/signature.dart';
import '../domain/signature_repository.dart';

class SqliteSignatureRepository implements SignatureRepository {
  const SqliteSignatureRepository(this._database);

  final AppDatabase _database;

  @override
  Future<void> add(Signature signature) async {
    await _database.db.insert(
      'signatures',
      signature.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<Signature>> list() async {
    final rows = await _database.db.query(
      'signatures',
      orderBy: 'created_at DESC',
    );
    return rows.map(Signature.fromMap).toList();
  }

  @override
  Future<void> delete(String id) async {
    await _database.db.delete(
      'signatures',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
