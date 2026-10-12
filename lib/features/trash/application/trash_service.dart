import 'package:flutter/foundation.dart';
import '../../../core/constants/app_config.dart';
import '../../../core/storage/document_file_store.dart';
import '../../../core/time/clock.dart';
import '../../documents/domain/document_repository.dart';
import '../domain/trash_repository.dart';

class TrashService {
  TrashService(
    this.trash,
    this.documents,
    this.files, {
    this.clock = systemClock,
  });

  final TrashRepository trash;
  final DocumentRepository documents;
  final DocumentFileStore files;
  final Clock clock;

  Future<int> purgeExpired({Duration? retention}) async {
    final deletedDocIds = await trash.purgeExpired(
      retention ?? AppConfig.trashRetention,
    );
    for (final docId in deletedDocIds) {
      await _safeDeleteDocumentDir(docId);
    }
    return deletedDocIds.length;
  }

  Future<void> deleteDocumentForever(String id) async {
    final deletedDocIds = await trash.deleteDocumentForever(id);
    for (final docId in deletedDocIds) {
      await _safeDeleteDocumentDir(docId);
    }
  }

  Future<void> deleteFolderForever(String id) async {
    final deletedDocIds = await trash.deleteFolderForever(id);
    for (final docId in deletedDocIds) {
      await _safeDeleteDocumentDir(docId);
    }
  }

  Future<void> emptyTrash() async {
    final deletedDocIds = await trash.emptyTrash();
    for (final docId in deletedDocIds) {
      await _safeDeleteDocumentDir(docId);
    }
  }

  Future<int> cleanOrphanDirectories() async {
    try {
      final dirIds = await files.listDocumentDirIds();
      if (dirIds.isEmpty) return 0;
      final existing = await documents.existingIds(dirIds);
      var removed = 0;
      for (final id in dirIds) {
        if (!existing.contains(id)) {
          await _safeDeleteDocumentDir(id);
          removed++;
        }
      }
      debugPrint('Cleaned $removed orphan document directories');
      return removed;
    } catch (error, stackTrace) {
      debugPrint('Failed to clean orphan directories: $error\n$stackTrace');
      return 0;
    }
  }

  Future<void> _safeDeleteDocumentDir(String documentId) async {
    try {
      await files.deleteDocumentDir(documentId);
    } catch (error, stackTrace) {
      debugPrint('Failed to delete files for document $documentId: $error\n$stackTrace');
    }
  }
}
