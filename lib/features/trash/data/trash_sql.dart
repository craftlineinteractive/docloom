abstract final class TrashSql {
  static const String listTrashedDocuments = '''
SELECT d.*,
  (SELECT COUNT(*) FROM pages p WHERE p.document_id = d.id) AS page_count,
  (SELECT COALESCE(p.edited_path, p.original_path) FROM pages p WHERE p.document_id = d.id AND p.position = 0) AS cover_path
FROM documents d
WHERE d.deleted_at IS NOT NULL
ORDER BY d.deleted_at DESC;
''';

  static const String listTrashedFolders = '''
SELECT f.*,
  (SELECT COUNT(*) FROM documents d WHERE d.folder_id = f.id AND d.deleted_at IS NULL) AS item_count
FROM folders f
WHERE f.deleted_at IS NOT NULL
ORDER BY f.deleted_at DESC;
''';
}
