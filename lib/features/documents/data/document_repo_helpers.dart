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
