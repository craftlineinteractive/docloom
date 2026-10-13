import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/providers/home_providers.dart';
import '../../../core/widgets/widgets.dart';
import '../../../core/providers/app_providers.dart';
import '../../documents/domain/document_repository.dart';
import '../../folders/domain/folder.dart';
import '../../folders/domain/folder_repository.dart';
import '../../trash/domain/restore_result.dart';
import '../../trash/domain/trash_repository.dart';

class LibraryActions {
  const LibraryActions({
    required this.folderRepo,
    required this.docRepo,
    required this.trashRepo,
  });

  final FolderRepository folderRepo;
  final DocumentRepository docRepo;
  final TrashRepository trashRepo;

  Future<Folder> createFolder({required String name, int colorIndex = 0}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw const ValidationException('Folder name cannot be empty');
    return folderRepo.create(name: trimmed, colorIndex: colorIndex);
  }

  Future<void> renameFolder({required String id, required String name}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw const ValidationException('Folder name cannot be empty');
    return folderRepo.rename(id, trimmed);
  }

  Future<void> setFolderColor({required String id, required int colorIndex}) {
    return folderRepo.setColor(id, colorIndex);
  }

  Future<void> deleteFolder(String id) {
    return folderRepo.moveToTrash(id);
  }

  Future<void> undoDeleteFolder(String id) {
    return trashRepo.restoreFolder(id);
  }

  Future<void> renameDocument({required String id, required String name}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw const ValidationException('Document name cannot be empty');
    return docRepo.rename(id, trimmed);
  }

  Future<void> toggleFavorite({required String id, required bool currentIsFavorite}) {
    return docRepo.setFavorite(id, !currentIsFavorite);
  }

  Future<void> moveDocument({required String id, String? targetFolderId}) {
    return docRepo.moveToFolder(id, targetFolderId);
  }

  Future<void> deleteDocument(String id) {
    return docRepo.moveToTrash(id);
  }

  Future<void> deleteDocuments(List<String> ids) async {
    for (final id in ids) {
      await docRepo.moveToTrash(id);
    }
  }

  Future<RestoreResult> undoDeleteDocument(String id) {
    return trashRepo.restoreDocument(id);
  }

  Future<void> undoDeleteDocuments(List<String> ids) {
    return trashRepo.restoreDocuments(ids);
  }

  Future<void> moveDocuments({required List<String> ids, String? targetFolderId}) async {
    for (final id in ids) {
      await docRepo.moveToFolder(id, targetFolderId);
    }
  }
}

final libraryActionsProvider = Provider<LibraryActions>((ref) {
  return LibraryActions(
    folderRepo: ref.watch(folderRepositoryProvider),
    docRepo: ref.watch(documentRepositoryProvider),
    trashRepo: ref.watch(trashRepositoryProvider),
  );
});

Future<void> batchDeleteWithToast(
  BuildContext context,
  WidgetRef ref,
  List<String> ids,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final actions = ref.read(libraryActionsProvider);
  ref.read(selectModeProvider.notifier).exit();
  ref.read(selectionProvider.notifier).clear();
  await actions.deleteDocuments(ids);
  ref.refreshLibrary();
  showAppToastWithMessenger(
    messenger,
    '${ids.length} documents moved to Trash',
    actionLabel: 'Undo',
    duration: const Duration(seconds: 5),
    onAction: () async {
      await actions.undoDeleteDocuments(ids);
      ref.refreshLibrary();
    },
  );
}

