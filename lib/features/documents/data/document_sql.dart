import 'package:docloom/features/documents/domain/document_sort.dart';

abstract final class DocumentSql {
  static const String joinFolder = 'LEFT JOIN folders f ON d.folder_id = f.id';

  static const String activeWhere =
      'd.deleted_at IS NULL AND (d.folder_id IS NULL OR (f.id IS NOT NULL AND f.deleted_at IS NULL))';

  static const String selectActiveById = '''
SELECT d.id
FROM documents d
$joinFolder
WHERE d.id = ? AND $activeWhere;
''';

  static const String selectActiveDocById = '''
SELECT d.*
FROM documents d
$joinFolder
WHERE d.id = ? AND $activeWhere;
''';

  static String orderClause(DocumentSort sort) => switch (sort) {
    DocumentSort.modifiedDesc => 'd.updated_at DESC',
    DocumentSort.modifiedAsc => 'd.updated_at ASC',
    DocumentSort.nameAsc => 'd.name COLLATE NOCASE ASC',
    DocumentSort.nameDesc => 'd.name COLLATE NOCASE DESC',
  };

  static String listInFolder({
    required bool isRoot,
    required DocumentSort sort,
  }) {
    final folderClause = isRoot ? 'd.folder_id IS NULL' : 'd.folder_id = ?';
    return '''
SELECT d.*,
  (SELECT COUNT(*) FROM pages p WHERE p.document_id = d.id) AS page_count,
  (SELECT COALESCE(p.edited_path, p.original_path) FROM pages p WHERE p.document_id = d.id AND p.position = 0) AS cover_path
FROM documents d
$joinFolder
WHERE $activeWhere AND $folderClause
ORDER BY ${orderClause(sort)};
''';
  }

  static const String searchActiveByName = '''
SELECT d.*,
  f.name AS folder_name,
  (SELECT COUNT(*) FROM pages p WHERE p.document_id = d.id) AS page_count,
  (SELECT COALESCE(p.edited_path, p.original_path) FROM pages p WHERE p.document_id = d.id AND p.position = 0) AS cover_path
FROM documents d
$joinFolder
WHERE $activeWhere AND d.name LIKE ? ESCAPE '\\'
ORDER BY d.updated_at DESC
LIMIT 100;
''';
}
