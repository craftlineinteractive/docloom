import 'package:sqflite/sqflite.dart';
import 'package:docloom/core/errors/app_exception.dart';
import 'package:docloom/core/time/clock.dart';
import 'document_sql.dart';

Future<void> assertFolderActive(DatabaseExecutor db, String folderId) async {
  final folder = await db.query(
    'folders',
    where: 'id = ? AND deleted_at IS NULL',
    whereArgs: [folderId],
  );
  if (folder.isEmpty) {
    throw const ValidationException('Folder does not exist or is in trash');
  }
}

Future<void> assertDocActive(DatabaseExecutor executor, String id) async {
  final rows = await executor.rawQuery(DocumentSql.selectActiveById, [id]);
  if (rows.isEmpty) {
    throw const NotFoundException('Document not found or trashed');
  }
}

Future<void> updateDocActive(
  DatabaseExecutor db,
  String id,
  Map<String, Object?> values, {
  required Clock clock,
}) async {
  await assertDocActive(db, id);
  values['updated_at'] = clock().millisecondsSinceEpoch;
  await db.update('documents', values, where: 'id = ?', whereArgs: [id]);
}

String escapeSqlLike(String input) {
  return input
      .replaceAll(r'\', r'\\')
      .replaceAll('%', r'\%')
      .replaceAll('_', r'\_');
}

Future<void> batchMoveToTrash(
  Database db,
  List<String> ids, {
  required Clock clock,
}) async {
  if (ids.isEmpty) return;
  await db.transaction((txn) async {
    final now = clock().millisecondsSinceEpoch;
    for (final id in ids) {
      final rows = await txn.query(
        'documents',
        columns: ['id', 'deleted_at'],
        where: 'id = ?',
        whereArgs: [id],
      );
      if (rows.isEmpty) {
        throw NotFoundException('Document not found: $id');
      }
      final row = rows.first;
      if (row['deleted_at'] != null) {
        continue;
      }
      await txn.update(
        'documents',
        {'deleted_at': now, 'updated_at': now},
        where: 'id = ? AND deleted_at IS NULL',
        whereArgs: [id],
      );
    }
  });
}

