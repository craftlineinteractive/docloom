import 'package:docloom/features/documents/domain/document_summary.dart';
import 'package:docloom/features/folders/domain/folder_summary.dart';
import 'restore_result.dart';

abstract interface class TrashRepository {
  Future<List<DocumentSummary>> listTrashedDocuments();
  Future<List<FolderSummary>> listTrashedFolders();
  Future<RestoreResult> restoreDocument(String id);
  Future<void> restoreFolder(String id);
  Future<List<String>> deleteDocumentForever(String id);
  Future<List<String>> deleteFolderForever(String id);
  Future<List<String>> emptyTrash();
  Future<List<String>> purgeExpired(Duration retention);
}
