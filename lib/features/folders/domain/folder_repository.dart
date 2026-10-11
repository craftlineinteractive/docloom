import 'folder.dart';
import 'folder_summary.dart';

abstract interface class FolderRepository {
  Future<Folder> create({required String name, int colorIndex = 0});
  Future<void> rename(String id, String name);
  Future<Folder?> getById(String id);
  Future<List<FolderSummary>> listActive();
  Future<void> moveToTrash(String id);
}
