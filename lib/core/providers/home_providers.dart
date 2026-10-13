import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/documents/domain/document_sort.dart';
import '../../features/documents/domain/document_summary.dart';
import '../../features/folders/domain/folder.dart';
import '../../features/folders/domain/folder_summary.dart';
import 'app_providers.dart';

class DocumentSortNotifier extends Notifier<DocumentSort> {
  @override
  DocumentSort build() => DocumentSort.modifiedDesc;

  void setSort(DocumentSort sort) => state = sort;
}

final documentSortProvider = NotifierProvider<DocumentSortNotifier, DocumentSort>(
  DocumentSortNotifier.new,
);

final foldersProvider = FutureProvider<List<FolderSummary>>((ref) {
  final repo = ref.watch(folderRepositoryProvider);
  return repo.listActive();
});

final documentsProvider = FutureProvider.family<List<DocumentSummary>, String?>((ref, folderId) {
  final repo = ref.watch(documentRepositoryProvider);
  final sort = ref.watch(documentSortProvider);
  return repo.listInFolder(folderId: folderId, sort: sort);
});

final folderByIdProvider = FutureProvider.family<Folder?, String>((ref, folderId) {
  final repo = ref.watch(folderRepositoryProvider);
  return repo.getById(folderId);
});

void refreshLibrary(WidgetRef ref) => ref.refreshLibrary();

extension RefreshLibraryWidgetRefX on WidgetRef {
  void refreshLibrary() {
    invalidate(foldersProvider);
    invalidate(documentsProvider);
    invalidate(folderByIdProvider);
  }
}

extension RefreshLibraryRefX on Ref {
  void refreshLibrary() {
    invalidate(foldersProvider);
    invalidate(documentsProvider);
    invalidate(folderByIdProvider);
  }
}

extension RefreshLibraryContainerX on ProviderContainer {
  void refreshLibrary() {
    invalidate(foldersProvider);
    invalidate(documentsProvider);
    invalidate(folderByIdProvider);
  }
}

