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
import 'trash_sql.dart';

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
    final rows = await db.db.rawQuery(TrashSql.listTrashedDocuments);
    return rows.map((r) => DocumentSummary(
      document: Document.fromMap(r),
      pageCount: r['page_count'] as int,
      coverPath: r['cover_path'] as String?,
    )).toList();
  }

  @override
  Future<List<FolderSummary>> listTrashedFolders() async {
    final rows = await db.db.rawQuery(TrashSql.listTrashedFolders);
    return rows.map((r) => FolderSummary(
      folder: Folder.fromMap(r),
      itemCount: r['item_count'] as int,
    )).toList();
  }

  @override
  Future<RestoreResult> restoreDocument(String id) async => (await restoreDocuments([id])).first;

  @override
  Future<List<RestoreResult>> restoreDocuments(List<String> ids) async {
    if (ids.isEmpty) return const [];
    return db.db.transaction((txn) async {
      final results = <RestoreResult>[];
      final now = clock().millisecondsSinceEpoch;
      for (final id in ids) {
        final docRows = await txn.query('documents', where: 'id = ?', whereArgs: [id]);
        if (docRows.isEmpty) throw const NotFoundException('Document not found in trash');
        final doc = docRows.first;
        if (doc['deleted_at'] == null) {
          results.add(const RestoreResult(restoredToRoot: false));
          continue;
        }
        final folderId = doc['folder_id'] as String?;
        if (folderId != null) {
          final activeFolder = await txn.query('folders', where: 'id = ? AND deleted_at IS NULL', whereArgs: [folderId]);
          if (activeFolder.isEmpty) {
            await txn.update('documents', {'deleted_at': null, 'folder_id': null, 'updated_at': now}, where: 'id = ?', whereArgs: [id]);
            results.add(const RestoreResult(restoredToRoot: true));
            continue;
          }
        }
        await txn.update('documents', {'deleted_at': null, 'updated_at': now}, where: 'id = ?', whereArgs: [id]);
        results.add(const RestoreResult(restoredToRoot: false));
      }
      return results;
    });
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
      final rows = await txn.query('documents', columns: ['id'], where: 'id = ? AND deleted_at IS NOT NULL', whereArgs: [id]);
      if (rows.isEmpty) return const [];
      await txn.delete('documents', where: 'id = ? AND deleted_at IS NOT NULL', whereArgs: [id]);
      return [id];
    });
  }

  @override
  Future<List<String>> deleteFolderForever(String id) async {
    return db.db.transaction((txn) async {
      final folderRows = await txn.query('folders', columns: ['id'], where: 'id = ? AND deleted_at IS NOT NULL', whereArgs: [id]);
      if (folderRows.isEmpty) return const [];
      final docRows = await txn.query('documents', columns: ['id'], where: 'folder_id = ?', whereArgs: [id]);
      final docIds = docRows.map((r) => r['id'] as String).toList();
      await txn.delete('documents', where: 'folder_id = ?', whereArgs: [id]);
      await txn.delete('folders', where: 'id = ? AND deleted_at IS NOT NULL', whereArgs: [id]);
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
