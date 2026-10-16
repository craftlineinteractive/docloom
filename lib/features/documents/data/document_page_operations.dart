import 'package:sqflite/sqflite.dart';
import 'package:docloom/core/errors/app_exception.dart';
import '../domain/new_page.dart';
import '../domain/scan_page.dart';

class DocumentPageOperations {
  const DocumentPageOperations();

  Future<void> insertPages(
    DatabaseExecutor txn, {
    required String documentId,
    required List<NewPage> pages,
    required DateTime createdAt,
    int startPosition = 0,
  }) async {
    for (var i = 0; i < pages.length; i++) {
      final page = pages[i];
      await txn.insert('pages', {
        'id': page.id,
        'document_id': documentId,
        'position': startPosition + i,
        'original_path': page.originalPath,
        'edited_path': page.editedPath,
        'filter_id': page.filterId,
        'rotation': page.rotation,
        'crop_json': page.cropJson,
        'created_at': createdAt.millisecondsSinceEpoch,
      });
    }
  }

  Future<ScanPage> deletePage(
    DatabaseExecutor txn, {
    required String pageId,
    required DateTime updatedAt,
  }) async {
    final pageRows = await txn.query(
      'pages',
      where: 'id = ?',
      whereArgs: [pageId],
    );
    if (pageRows.isEmpty) {
      throw const NotFoundException('Page not found');
    }
    final deleted = ScanPage.fromMap(pageRows.first);

    final countResult = await txn.rawQuery(
      'SELECT COUNT(*) AS total FROM pages WHERE document_id = ?;',
      [deleted.documentId],
    );
    final count = (countResult.first['total'] as int?) ?? 0;
    if (count <= 1) {
      throw const ValidationException('Cannot delete the last page of a document');
    }

    await txn.delete('pages', where: 'id = ?', whereArgs: [pageId]);

    final remaining = await txn.query(
      'pages',
      columns: ['id'],
      where: 'document_id = ?',
      whereArgs: [deleted.documentId],
      orderBy: 'position ASC',
    );
    for (var i = 0; i < remaining.length; i++) {
      await txn.update(
        'pages',
        {'position': i},
        where: 'id = ?',
        whereArgs: [remaining[i]['id'] as String],
      );
    }

    await txn.update(
      'documents',
      {'updated_at': updatedAt.millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [deleted.documentId],
    );

    return deleted;
  }

  Future<void> reorderPages(
    DatabaseExecutor txn, {
    required String documentId,
    required List<String> orderedPageIds,
    required DateTime updatedAt,
  }) async {
    final existing = await txn.query(
      'pages',
      columns: ['id'],
      where: 'document_id = ?',
      whereArgs: [documentId],
    );
    final existingIds = existing.map((e) => e['id'] as String).toSet();
    if (orderedPageIds.length != existingIds.length ||
        orderedPageIds.toSet().difference(existingIds).isNotEmpty) {
      throw const ValidationException('Ordered page IDs must match document pages exactly');
    }

    for (var i = 0; i < orderedPageIds.length; i++) {
      await txn.update(
        'pages',
        {'position': i},
        where: 'id = ? AND document_id = ?',
        whereArgs: [orderedPageIds[i], documentId],
      );
    }

    await txn.update(
      'documents',
      {'updated_at': updatedAt.millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [documentId],
    );
  }
}
