import 'document.dart';
import 'document_sort.dart';
import 'document_summary.dart';
import 'new_page.dart';
import 'scan_page.dart';

abstract interface class DocumentRepository {
  Future<Document> createWithPages({
    required String id,
    required String name,
    String? folderId,
    required List<NewPage> pages,
  });

  Future<Document?> getById(String id);
  Future<List<ScanPage>> getPages(String documentId);

  Future<List<DocumentSummary>> listInFolder({
    String? folderId,
    DocumentSort sort = DocumentSort.modifiedDesc,
  });

  Future<void> rename(String id, String name);
  Future<void> setFavorite(String id, bool value);
  Future<void> setNote(String id, String? note);
  Future<void> moveToFolder(String id, String? folderId);

  Future<void> addPages(String documentId, List<NewPage> pages);
  Future<ScanPage> deletePage(String pageId);
  Future<void> reorderPages(String documentId, List<String> orderedPageIds);
  Future<void> moveToTrash(String id);
  Future<Set<String>> existingIds(List<String> ids);
  Future<List<DocumentSummary>> searchByName(String query);
}
