import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/app_providers.dart';
import '../documents/domain/document_sort.dart';
import '../documents/domain/new_page.dart';
import 'seed_data.dart';

class DbCheckActions {
  const DbCheckActions({required this.ref, required this.addLog});

  final WidgetRef ref;
  final void Function(String) addLog;

  Future<void> createFolder(int seq) async {
    final folder = await ref.read(folderRepositoryProvider).create(name: 'Test Folder $seq');
    addLog('Created folder "${folder.name}" (${folder.id})');
  }

  Future<void> createDoc() async {
    final idGen = ref.read(idGeneratorProvider);
    final fileStore = ref.read(fileStoreProvider);
    final docId = idGen(), p1Id = idGen(), p2Id = idGen();
    final rel1 = await fileStore.writeEdited(documentId: docId, pageId: p1Id, bytes: const [0, 1, 2]);
    final rel2 = await fileStore.writeEdited(documentId: docId, pageId: p2Id, bytes: const [3, 4, 5]);
    final doc = await ref.read(documentRepositoryProvider).createWithPages(
      id: docId,
      name: 'Doc ${DateTime.now().millisecondsSinceEpoch % 1000}',
      pages: [NewPage(id: p1Id, originalPath: rel1), NewPage(id: p2Id, originalPath: rel2)],
    );
    addLog('Created doc "${doc.name}" with 2 pages');
  }

  Future<void> trashNewestDoc() async {
    final docs = await ref.read(documentRepositoryProvider).listInFolder(sort: DocumentSort.modifiedDesc);
    if (docs.isEmpty) return addLog('No root documents to trash');
    await ref.read(documentRepositoryProvider).moveToTrash(docs.first.document.id);
    addLog('Trashed doc "${docs.first.document.name}"');
  }

  Future<void> restoreNewestDoc() async {
    final trashed = await ref.read(trashRepositoryProvider).listTrashedDocuments();
    if (trashed.isEmpty) return addLog('No trashed documents to restore');
    final res = await ref.read(trashRepositoryProvider).restoreDocument(trashed.first.document.id);
    addLog('Restored "${trashed.first.document.name}" (toRoot: ${res.restoredToRoot})');
  }

  Future<void> emptyTrash() async {
    final trashedDocs = await ref.read(trashRepositoryProvider).listTrashedDocuments();
    final trashedFolders = await ref.read(trashRepositoryProvider).listTrashedFolders();
    if (trashedDocs.isEmpty && trashedFolders.isEmpty) return addLog('Trash is already empty');
    await ref.read(trashServiceProvider).emptyTrash();
    addLog('Emptied trash');
  }

  Future<void> seedData() async {
    final res = await seedSampleData(
      folderRepo: ref.read(folderRepositoryProvider),
      docRepo: ref.read(documentRepositoryProvider),
      trashService: ref.read(trashServiceProvider),
      fileStore: ref.read(fileStoreProvider),
      idGen: ref.read(idGeneratorProvider),
    );
    addLog('Seeded ${res.foldersCount} folders, ${res.docsCount} docs, ${res.trashedCount} trashed');
  }

  Future<void> clearAll() async {
    await clearAllData(
      folderRepo: ref.read(folderRepositoryProvider),
      docRepo: ref.read(documentRepositoryProvider),
      trashService: ref.read(trashServiceProvider),
    );
    addLog('Cleared all folders and documents');
  }
}
