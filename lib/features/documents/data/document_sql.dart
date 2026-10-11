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

  static String listInFolder({
    required bool isRoot,
    required String orderBy,
  }) {
    final folderClause = isRoot ? 'd.folder_id IS NULL' : 'd.folder_id = ?';
    return '''
SELECT d.*,
  (SELECT COUNT(*) FROM pages p WHERE p.document_id = d.id) AS page_count,
  (SELECT COALESCE(p.edited_path, p.original_path) FROM pages p WHERE p.document_id = d.id AND p.position = 0) AS cover_path
FROM documents d
$joinFolder
WHERE $activeWhere AND $folderClause
ORDER BY $orderBy;
''';
  }
}
