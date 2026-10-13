import 'package:docloom/core/db/app_database.dart';
import 'package:docloom/core/errors/app_exception.dart';
import 'package:docloom/core/ids/id_generator.dart';
import 'package:docloom/core/time/clock.dart';
import '../domain/document.dart';
import '../domain/document_repository.dart';
import '../domain/document_sort.dart';
import '../domain/document_summary.dart';
import '../domain/new_page.dart';
import '../domain/scan_page.dart';
import 'document_page_operations.dart';
import 'document_repo_helpers.dart';
import 'document_sql.dart';

class SqliteDocumentRepository implements DocumentRepository {
  SqliteDocumentRepository(this.db, {this.clock = systemClock, IdGenerator idGenerator = newId})
      : _pageOps = const DocumentPageOperations();

  final AppDatabase db;
  final Clock clock;
  final DocumentPageOperations _pageOps;

  @override
  Future<Document> createWithPages({
    required String id,
    required String name,
    String? folderId,
    required List<NewPage> pages,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw const ValidationException('Document name cannot be empty');
    if (pages.isEmpty) throw const ValidationException('Document must have at least one page');
    if (folderId != null) await assertFolderActive(db.db, folderId);

    final now = clock();
    final document = Document(id: id, folderId: folderId, name: trimmed, createdAt: now, updatedAt: now);
    await db.db.transaction((txn) async {
      await txn.insert('documents', document.toMap());
      await _pageOps.insertPages(txn, documentId: id, pages: pages, createdAt: now);
    });
    return document;
  }

  @override
  Future<Document?> getById(String id) async {
    final rows = await db.db.rawQuery(DocumentSql.selectActiveDocById, [id]);
    return rows.isEmpty ? null : Document.fromMap(rows.first);
  }

  @override
  Future<List<ScanPage>> getPages(String documentId) async {
    final active = await db.db.rawQuery(DocumentSql.selectActiveById, [documentId]);
    if (active.isEmpty) return const [];
    final rows = await db.db.query('pages', where: 'document_id = ?', whereArgs: [documentId], orderBy: 'position ASC');
    return rows.map(ScanPage.fromMap).toList();
  }

  @override
  Future<List<DocumentSummary>> listInFolder({String? folderId, DocumentSort sort = DocumentSort.modifiedDesc}) async {
    final sql = DocumentSql.listInFolder(isRoot: folderId == null, sort: sort);
    final rows = await db.db.rawQuery(sql, folderId == null ? const [] : [folderId]);
    return rows.map((r) => DocumentSummary(
      document: Document.fromMap(r), pageCount: r['page_count'] as int, coverPath: r['cover_path'] as String?,
    )).toList();
  }

  @override
  Future<void> rename(String id, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw const ValidationException('Document name cannot be empty');
    await updateDocActive(db.db, id, {'name': trimmed}, clock: clock);
  }

  @override
  Future<void> setFavorite(String id, bool value) =>
      updateDocActive(db.db, id, {'is_favorite': value ? 1 : 0}, clock: clock);

  @override
  Future<void> setNote(String id, String? note) =>
      updateDocActive(db.db, id, {'note': note}, clock: clock);

  @override
  Future<void> moveToFolder(String id, String? folderId) async {
    if (folderId != null) await assertFolderActive(db.db, folderId);
    await updateDocActive(db.db, id, {'folder_id': folderId}, clock: clock);
  }

  @override
  Future<void> addPages(String documentId, List<NewPage> pages) async {
    if (pages.isEmpty) return;
    await db.db.transaction((txn) async {
      await assertDocActive(txn, documentId);
      final max = await txn.rawQuery('SELECT MAX(position) AS p FROM pages WHERE document_id = ?;', [documentId]);
      final start = ((max.first['p'] as int?) ?? -1) + 1;
      final now = clock();
      await _pageOps.insertPages(txn, documentId: documentId, pages: pages, createdAt: now, startPosition: start);
      await txn.update('documents', {'updated_at': now.millisecondsSinceEpoch}, where: 'id = ?', whereArgs: [documentId]);
    });
  }

  @override
  Future<ScanPage> deletePage(String pageId) => db.db.transaction((txn) async {
    final rows = await txn.query('pages', where: 'id = ?', whereArgs: [pageId]);
    if (rows.isEmpty) throw const NotFoundException('Page not found');
    await assertDocActive(txn, rows.first['document_id'] as String);
    return _pageOps.deletePage(txn, pageId: pageId, updatedAt: clock());
  });

  @override
  Future<void> reorderPages(String documentId, List<String> orderedPageIds) =>
      db.db.transaction((txn) async {
        await assertDocActive(txn, documentId);
        await _pageOps.reorderPages(txn, documentId: documentId, orderedPageIds: orderedPageIds, updatedAt: clock());
      });

  @override
  Future<void> moveToTrash(String id) async {
    final doc = await db.db.query('documents', columns: ['id', 'deleted_at'], where: 'id = ?', whereArgs: [id]);
    if (doc.isEmpty) throw const NotFoundException('Document not found');
    if (doc.first['deleted_at'] != null) return;
    final ms = clock().millisecondsSinceEpoch;
    await db.db.update('documents', {'deleted_at': ms, 'updated_at': ms}, where: 'id = ? AND deleted_at IS NULL', whereArgs: [id]);
  }

  @override
  Future<Set<String>> existingIds(List<String> ids) async {
    if (ids.isEmpty) return const {};
    final placeholders = List.filled(ids.length, '?').join(', ');
    final rows = await db.db.query('documents', columns: ['id'], where: 'id IN ($placeholders)', whereArgs: ids);
    return rows.map((r) => r['id'] as String).toSet();
  }

  @override
  Future<List<DocumentSummary>> searchByName(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];
    final escaped = escapeSqlLike(trimmed);
    final rows = await db.db.rawQuery(DocumentSql.searchActiveByName, ['%$escaped%']);
    return rows.map((r) => DocumentSummary(
          document: Document.fromMap(r),
          pageCount: r['page_count'] as int,
          coverPath: r['cover_path'] as String?,
          folderName: r['folder_name'] as String?,
        )).toList();
  }
}
