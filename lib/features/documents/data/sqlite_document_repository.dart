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

class SqliteDocumentRepository implements DocumentRepository {
  SqliteDocumentRepository(
    this.db, {
    this.clock = systemClock,
    IdGenerator idGenerator = newId,
  }) : _pageOps = const DocumentPageOperations();

  final AppDatabase db;
  final Clock clock;
  final DocumentPageOperations _pageOps;

  Future<void> _assertFolderActive(String folderId) async {
    final folder = await db.db.query('folders', where: 'id = ? AND deleted_at IS NULL', whereArgs: [folderId]);
    if (folder.isEmpty) throw const ValidationException('Folder does not exist or is in trash');
  }

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
    if (folderId != null) await _assertFolderActive(folderId);

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
    final rows = await db.db.query('documents', where: 'id = ? AND deleted_at IS NULL', whereArgs: [id]);
    return rows.isEmpty ? null : Document.fromMap(rows.first);
  }

  @override
  Future<List<ScanPage>> getPages(String documentId) async {
    final rows = await db.db.query('pages', where: 'document_id = ?', whereArgs: [documentId], orderBy: 'position ASC');
    return rows.map(ScanPage.fromMap).toList();
  }

  @override
  Future<List<DocumentSummary>> listInFolder({String? folderId, DocumentSort sort = DocumentSort.modifiedDesc}) async {
    final order = switch (sort) {
      DocumentSort.modifiedDesc => 'd.updated_at DESC',
      DocumentSort.modifiedAsc => 'd.updated_at ASC',
      DocumentSort.nameAsc => 'd.name COLLATE NOCASE ASC',
      DocumentSort.nameDesc => 'd.name COLLATE NOCASE DESC',
    };
    final sql = '''
SELECT d.*,
  (SELECT COUNT(*) FROM pages p WHERE p.document_id = d.id) AS page_count,
  (SELECT COALESCE(p.edited_path, p.original_path) FROM pages p WHERE p.document_id = d.id AND p.position = 0) AS cover_path
FROM documents d
WHERE d.deleted_at IS NULL AND ${folderId == null ? 'd.folder_id IS NULL' : 'd.folder_id = ?'}
ORDER BY $order;''';
    final rows = await db.db.rawQuery(sql, folderId == null ? const [] : [folderId]);
    return rows.map((r) => DocumentSummary(
      document: Document.fromMap(r),
      pageCount: r['page_count'] as int,
      coverPath: r['cover_path'] as String?,
    )).toList();
  }

  @override
  Future<void> rename(String id, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw const ValidationException('Document name cannot be empty');
    final rows = await db.db.update('documents', {'name': trimmed, 'updated_at': clock().millisecondsSinceEpoch}, where: 'id = ? AND deleted_at IS NULL', whereArgs: [id]);
    if (rows == 0) throw const NotFoundException('Document not found or trashed');
  }

  @override
  Future<void> setFavorite(String id, bool value) async {
    final rows = await db.db.update('documents', {'is_favorite': value ? 1 : 0, 'updated_at': clock().millisecondsSinceEpoch}, where: 'id = ? AND deleted_at IS NULL', whereArgs: [id]);
    if (rows == 0) throw const NotFoundException('Document not found or trashed');
  }

  @override
  Future<void> setNote(String id, String? note) async {
    final rows = await db.db.update('documents', {'note': note, 'updated_at': clock().millisecondsSinceEpoch}, where: 'id = ? AND deleted_at IS NULL', whereArgs: [id]);
    if (rows == 0) throw const NotFoundException('Document not found or trashed');
  }

  @override
  Future<void> moveToFolder(String id, String? folderId) async {
    if (folderId != null) await _assertFolderActive(folderId);
    final rows = await db.db.update('documents', {'folder_id': folderId, 'updated_at': clock().millisecondsSinceEpoch}, where: 'id = ? AND deleted_at IS NULL', whereArgs: [id]);
    if (rows == 0) throw const NotFoundException('Document not found or trashed');
  }

  @override
  Future<void> addPages(String documentId, List<NewPage> pages) async {
    if (pages.isEmpty) return;
    await db.db.transaction((txn) async {
      final doc = await txn.query('documents', where: 'id = ? AND deleted_at IS NULL', whereArgs: [documentId]);
      if (doc.isEmpty) throw const NotFoundException('Document not found or trashed');
      final maxResult = await txn.rawQuery('SELECT MAX(position) AS max_pos FROM pages WHERE document_id = ?;', [documentId]);
      final maxPos = maxResult.first['max_pos'] as int?;
      final startPos = maxPos != null ? maxPos + 1 : 0;
      final now = clock();
      await _pageOps.insertPages(txn, documentId: documentId, pages: pages, createdAt: now, startPosition: startPos);
      await txn.update('documents', {'updated_at': now.millisecondsSinceEpoch}, where: 'id = ?', whereArgs: [documentId]);
    });
  }

  @override
  Future<ScanPage> deletePage(String pageId) => db.db.transaction((txn) => _pageOps.deletePage(txn, pageId: pageId, updatedAt: clock()));

  @override
  Future<void> reorderPages(String documentId, List<String> orderedPageIds) async {
    await db.db.transaction((txn) async {
      final doc = await txn.query('documents', where: 'id = ? AND deleted_at IS NULL', whereArgs: [documentId]);
      if (doc.isEmpty) throw const NotFoundException('Document not found or trashed');
      await _pageOps.reorderPages(txn, documentId: documentId, orderedPageIds: orderedPageIds, updatedAt: clock());
    });
  }

  @override
  Future<void> moveToTrash(String id) async {
    final now = clock();
    final count = await db.db.update('documents', {'deleted_at': now.millisecondsSinceEpoch, 'updated_at': now.millisecondsSinceEpoch}, where: 'id = ? AND deleted_at IS NULL', whereArgs: [id]);
    if (count == 0) throw const NotFoundException('Document not found or already trashed');
  }
}
