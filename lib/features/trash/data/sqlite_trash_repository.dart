import 'package:docloom/core/db/app_database.dart';
import 'package:docloom/core/errors/app_exception.dart';
import 'package:docloom/core/ids/id_generator.dart';
import 'package:docloom/core/time/clock.dart';
import 'package:docloom/features/documents/domain/document.dart';
import 'package:docloom/features/documents/domain/document_summary.dart';
import 'package:docloom/features/folders/domain/folder.dart';
import 'package:docloom/features/folders/domain/folder_summary.dart';
import '../domain/restore_result.dart';
import '../domain/trash_repository.dart';

class SqliteTrashRepository implements TrashRepository {
  SqliteTrashRepository(
    this.db, {
    this.clock = systemClock,
    IdGenerator idGenerator = newId,
  });

  final AppDatabase db;
  final Clock clock;

  @override
  Future<List<DocumentSummary>> listTrashedDocuments() async {
    const sql = '''
SELECT d.*,
  (SELECT COUNT(*) FROM pages p WHERE p.document_id = d.id) AS page_count,
  (SELECT COALESCE(p.edited_path, p.original_path) FROM pages p WHERE p.document_id = d.id AND p.position = 0) AS cover_path
FROM documents d
WHERE d.deleted_at IS NOT NULL
ORDER BY d.deleted_at DESC;''';
    final rows = await db.db.rawQuery(sql);
    return rows.map((r) => DocumentSummary(
      document: Document.fromMap(r),
      pageCount: r['page_count'] as int,
      coverPath: r['cover_path'] as String?,
    )).toList();
  }

  @override
  Future<List<FolderSummary>> listTrashedFolders() async {
    const sql = '''
SELECT f.*,
  (SELECT COUNT(*) FROM documents d WHERE d.folder_id = f.id) AS item_count
FROM folders f
WHERE f.deleted_at IS NOT NULL
ORDER BY f.deleted_at DESC;''';
    final rows = await db.db.rawQuery(sql);
    return rows.map((r) => FolderSummary(
      folder: Folder.fromMap(r),
      itemCount: r['item_count'] as int,
    )).toList();
  }

  @override
  Future<RestoreResult> restoreDocument(String id) async {
    final docRows = await db.db.query('documents', where: 'id = ? AND deleted_at IS NOT NULL', whereArgs: [id]);
    if (docRows.isEmpty) throw const NotFoundException('Document not found in trash');
    final folderId = docRows.first['folder_id'] as String?;
    final now = clock().millisecondsSinceEpoch;
    var restoredToRoot = false;

    if (folderId != null) {
      final activeFolder = await db.db.query('folders', where: 'id = ? AND deleted_at IS NULL', whereArgs: [folderId]);
      if (activeFolder.isEmpty) {
        restoredToRoot = true;
        await db.db.update('documents', {'deleted_at': null, 'folder_id': null, 'updated_at': now}, where: 'id = ?', whereArgs: [id]);
        return RestoreResult(restoredToRoot: restoredToRoot);
      }
    }
    await db.db.update('documents', {'deleted_at': null, 'updated_at': now}, where: 'id = ?', whereArgs: [id]);
    return const RestoreResult(restoredToRoot: false);
  }

  @override
  Future<void> restoreFolder(String id) async {
    final now = clock().millisecondsSinceEpoch;
    final count = await db.db.update('folders', {'deleted_at': null, 'updated_at': now}, where: 'id = ? AND deleted_at IS NOT NULL', whereArgs: [id]);
    if (count == 0) throw const NotFoundException('Folder not found in trash');
  }

  @override
  Future<List<String>> deleteDocumentForever(String id) async {
    return db.db.transaction((txn) async {
      final rows = await txn.query('documents', columns: ['id'], where: 'id = ?', whereArgs: [id]);
      if (rows.isEmpty) return const [];
      await txn.delete('documents', where: 'id = ?', whereArgs: [id]);
      return [id];
    });
  }

  @override
  Future<List<String>> deleteFolderForever(String id) async {
    return db.db.transaction((txn) async {
      final docRows = await txn.query('documents', columns: ['id'], where: 'folder_id = ?', whereArgs: [id]);
      final docIds = docRows.map((r) => r['id'] as String).toList();
      await txn.delete('documents', where: 'folder_id = ?', whereArgs: [id]);
      await txn.delete('folders', where: 'id = ?', whereArgs: [id]);
      return docIds;
    });
  }

  @override
  Future<List<String>> emptyTrash() async {
    return db.db.transaction((txn) async {
      final trashedFolders = await txn.query('folders', columns: ['id'], where: 'deleted_at IS NOT NULL');
      final folderIds = trashedFolders.map((r) => r['id'] as String).toList();
      final deletedDocIds = <String>{};
      for (final fid in folderIds) {
        final dRows = await txn.query('documents', columns: ['id'], where: 'folder_id = ?', whereArgs: [fid]);
        deletedDocIds.addAll(dRows.map((r) => r['id'] as String));
      }
      final directDocs = await txn.query('documents', columns: ['id'], where: 'deleted_at IS NOT NULL');
      deletedDocIds.addAll(directDocs.map((r) => r['id'] as String));

      for (final docId in deletedDocIds) {
        await txn.delete('documents', where: 'id = ?', whereArgs: [docId]);
      }
      await txn.delete('folders', where: 'deleted_at IS NOT NULL');
      return deletedDocIds.toList();
    });
  }

  @override
  Future<List<String>> purgeExpired(Duration retention) async {
    final cutoff = clock().subtract(retention).millisecondsSinceEpoch;
    return db.db.transaction((txn) async {
      final expFolders = await txn.query('folders', columns: ['id'], where: 'deleted_at IS NOT NULL AND deleted_at <= ?', whereArgs: [cutoff]);
      final folderIds = expFolders.map((r) => r['id'] as String).toList();
      final purgedDocIds = <String>{};
      for (final fid in folderIds) {
        final dRows = await txn.query('documents', columns: ['id'], where: 'folder_id = ?', whereArgs: [fid]);
        purgedDocIds.addAll(dRows.map((r) => r['id'] as String));
      }
      final expDocs = await txn.query('documents', columns: ['id'], where: 'deleted_at IS NOT NULL AND deleted_at <= ?', whereArgs: [cutoff]);
      purgedDocIds.addAll(expDocs.map((r) => r['id'] as String));

      for (final docId in purgedDocIds) {
        await txn.delete('documents', where: 'id = ?', whereArgs: [docId]);
      }
      await txn.delete('folders', where: 'deleted_at IS NOT NULL AND deleted_at <= ?', whereArgs: [cutoff]);
      return purgedDocIds.toList();
    });
  }
}
