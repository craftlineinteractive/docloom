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

String documentSortLabel(DocumentSort sort) => switch (sort) {
  DocumentSort.modifiedDesc => 'Modified (newest)',
  DocumentSort.modifiedAsc => 'Modified (oldest)',
  DocumentSort.nameAsc => 'Name (A-Z)',
  DocumentSort.nameDesc => 'Name (Z-A)',
};

enum ViewMode { list, grid }

class ViewModeNotifier extends Notifier<ViewMode> {
  @override
  ViewMode build() => ViewMode.list;

  void toggle() => state = state == ViewMode.list ? ViewMode.grid : ViewMode.list;
  void setMode(ViewMode mode) => state = mode;
}

final viewModeProvider = NotifierProvider<ViewModeNotifier, ViewMode>(
  ViewModeNotifier.new,
);

class SelectionNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  void toggle(String id) {
    final next = Set<String>.from(state);
    if (!next.remove(id)) next.add(id);
    state = next;
  }

  void selectAll(Iterable<String> ids) => state = ids.toSet();
  void clear() => state = const {};
}

final selectionProvider = NotifierProvider<SelectionNotifier, Set<String>>(
  SelectionNotifier.new,
);

class SelectModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void enter() => state = true;
  void exit() => state = false;
}

final selectModeProvider = NotifierProvider<SelectModeNotifier, bool>(
  SelectModeNotifier.new,
);

final foldersProvider = FutureProvider<List<FolderSummary>>((ref) async {
  final repo = ref.watch(folderRepositoryProvider);
  final sort = ref.watch(documentSortProvider);
  final list = await repo.listActive();
  final sorted = List<FolderSummary>.from(list);
  switch (sort) {
    case DocumentSort.modifiedDesc:
      sorted.sort((a, b) => b.folder.updatedAt.compareTo(a.folder.updatedAt));
    case DocumentSort.modifiedAsc:
      sorted.sort((a, b) => a.folder.updatedAt.compareTo(b.folder.updatedAt));
    case DocumentSort.nameAsc:
      sorted.sort((a, b) => a.folder.name.toLowerCase().compareTo(b.folder.name.toLowerCase()));
    case DocumentSort.nameDesc:
      sorted.sort((a, b) => b.folder.name.toLowerCase().compareTo(a.folder.name.toLowerCase()));
  }
  return sorted;
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

