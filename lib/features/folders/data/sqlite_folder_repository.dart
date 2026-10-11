import 'package:docloom/core/db/app_database.dart';
import 'package:docloom/core/errors/app_exception.dart';
import 'package:docloom/core/ids/id_generator.dart';
import 'package:docloom/core/time/clock.dart';
import '../domain/folder.dart';
import '../domain/folder_repository.dart';
import '../domain/folder_summary.dart';

class SqliteFolderRepository implements FolderRepository {
  SqliteFolderRepository(
    this.db, {
    this.clock = systemClock,
    this.idGenerator = newId,
  });

  final AppDatabase db;
  final Clock clock;
  final IdGenerator idGenerator;

  @override
  Future<Folder> create({required String name, int colorIndex = 0}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const ValidationException('Folder name cannot be empty');
    }
    final now = clock();
    final folder = Folder(
      id: idGenerator(),
      name: trimmed,
      colorIndex: colorIndex,
      createdAt: now,
      updatedAt: now,
    );
    await db.db.insert('folders', folder.toMap());
    return folder;
  }

  @override
  Future<void> rename(String id, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const ValidationException('Folder name cannot be empty');
    }
    final now = clock();
    final count = await db.db.update(
      'folders',
      {
        'name': trimmed,
        'updated_at': now.millisecondsSinceEpoch,
      },
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [id],
    );
    if (count == 0) {
      throw const NotFoundException('Folder not found or trashed');
    }
  }

  @override
  Future<Folder?> getById(String id) async {
    final rows = await db.db.query(
      'folders',
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return Folder.fromMap(rows.first);
  }

  @override
  Future<List<FolderSummary>> listActive() async {
    final rows = await db.db.rawQuery(
      '''
SELECT f.*, (
  SELECT COUNT(*) FROM documents d
  WHERE d.folder_id = f.id AND d.deleted_at IS NULL
) AS item_count
FROM folders f
WHERE f.deleted_at IS NULL
ORDER BY f.name COLLATE NOCASE ASC;
''',
    );
    return rows
        .map(
          (row) => FolderSummary(
            folder: Folder.fromMap(row),
            itemCount: row['item_count'] as int,
          ),
        )
        .toList();
  }

  @override
  Future<void> moveToTrash(String id) async {
    final folder = await db.db.query(
      'folders',
      columns: ['id', 'deleted_at'],
      where: 'id = ?',
      whereArgs: [id],
    );
    if (folder.isEmpty) {
      throw const NotFoundException('Folder not found');
    }
    if (folder.first['deleted_at'] != null) return;
    final now = clock();
    await db.db.update(
      'folders',
      {
        'deleted_at': now.millisecondsSinceEpoch,
        'updated_at': now.millisecondsSinceEpoch,
      },
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [id],
    );
  }
}
