import 'dart:io';
import 'package:path/path.dart' as p;
import '../../../core/errors/app_exception.dart';
import '../../../core/ids/id_generator.dart';
import '../../../core/storage/document_file_store.dart';
import '../../../core/storage/thumbnail_generator.dart';
import '../../../core/time/clock.dart';
import '../../documents/domain/document.dart';
import '../../documents/domain/document_repository.dart';
import '../../documents/domain/new_page.dart';
import '../domain/document_namer.dart';
import '../domain/scanned_page.dart';

class ScanSaveService {
  ScanSaveService(
    this._documentRepository,
    this._fileStore, {
    Clock? clock,
    IdGenerator? idGenerator,
    ThumbnailGenerator? thumbnailGenerator,
  })  : _clock = clock ?? systemClock,
        _idGenerator = idGenerator ?? newId,
        _thumbnailGenerator = thumbnailGenerator ?? const ThumbnailGenerator();

  final DocumentRepository _documentRepository;
  final DocumentFileStore _fileStore;
  final Clock _clock;
  final IdGenerator _idGenerator;
  final ThumbnailGenerator _thumbnailGenerator;

  Future<Document> save({
    required List<ScannedPage> pages,
    String? folderId,
    String? name,
  }) async {
    if (pages.isEmpty) {
      throw const ValidationException('Cannot save document with zero pages');
    }

    final trimmed = name?.trim();
    final docName = (trimmed != null && trimmed.isNotEmpty)
        ? trimmed
        : defaultDocumentName(_clock().toLocal());

    final documentId = _idGenerator();
    final pageIds = List.generate(pages.length, (_) => _idGenerator());

    try {
      final newPages = <NewPage>[];
      for (var i = 0; i < pages.length; i++) {
        final page = pages[i];
        final pageId = pageIds[i];
        final origFile = File(page.originalPath);
        if (!await origFile.exists()) {
          throw NotFoundException('Original file not found: ${page.originalPath}');
        }
        final savedOrigPath = await _fileStore.importOriginal(
          documentId: documentId,
          pageId: pageId,
          source: origFile,
        );

        String? savedEditedPath;
        File thumbSource = origFile;
        if (page.editedPath != null) {
          final editedFile = File(page.editedPath!);
          if (!await editedFile.exists()) {
            throw NotFoundException('Edited file not found: ${page.editedPath}');
          }
          final bytes = await editedFile.readAsBytes();
          final rawExt = p.extension(editedFile.path).replaceAll('.', '');
          savedEditedPath = await _fileStore.writeEdited(
            documentId: documentId,
            pageId: pageId,
            bytes: bytes,
            ext: rawExt.isEmpty ? 'jpg' : rawExt,
          );
          thumbSource = editedFile;
        }

        if (i == 0) {
          try {
            final thumbBytes = await _thumbnailGenerator.generateFromFile(thumbSource);
            await _fileStore.writeThumbnail(
              documentId: documentId,
              pageId: pageId,
              bytes: thumbBytes,
            );
          } catch (_) {}
        }

        newPages.add(NewPage(
          id: pageId,
          originalPath: savedOrigPath,
          editedPath: savedEditedPath,
          filterId: page.filterId,
          rotation: page.rotation,
          cropJson: page.cropJson,
        ));
      }

      final doc = await _documentRepository.createWithPages(
        id: documentId,
        name: docName,
        folderId: folderId,
        pages: newPages,
      );

      _cleanSessionDir(pages.first.originalPath);
      return doc;
    } catch (_) {
      await _fileStore.deleteDocumentDir(documentId);
      rethrow;
    }
  }

  void _cleanSessionDir(String anyPagePath) {
    try {
      final parentDir = File(anyPagePath).parent;
      if (parentDir.existsSync()) {
        parentDir.deleteSync(recursive: true);
      }
    } catch (_) {}
  }
}
