abstract final class AppDatabaseSchema {
  static const List<String> v1 = [
    '''
CREATE TABLE folders (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  color_index INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  deleted_at INTEGER
);''',
    '''
CREATE TABLE documents (
  id TEXT PRIMARY KEY,
  folder_id TEXT REFERENCES folders(id),
  name TEXT NOT NULL,
  is_favorite INTEGER NOT NULL DEFAULT 0,
  note TEXT,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  deleted_at INTEGER
);''',
    '''
CREATE TABLE pages (
  id TEXT PRIMARY KEY,
  document_id TEXT NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
  position INTEGER NOT NULL,
  original_path TEXT NOT NULL,
  edited_path TEXT,
  filter_id TEXT NOT NULL DEFAULT 'original',
  rotation INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL
);''',
    'CREATE INDEX idx_documents_folder ON documents(folder_id, deleted_at);',
    'CREATE INDEX idx_documents_deleted ON documents(deleted_at);',
    'CREATE INDEX idx_pages_document ON pages(document_id, position);',
    'CREATE INDEX idx_folders_deleted ON folders(deleted_at);',
  ];
}
