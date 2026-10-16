import 'dart:io';
import 'package:path/path.dart' as p;

class DocumentFileStore {
  const DocumentFileStore(this.root);

  final Directory root;

  Future<String> importOriginal({
    required String documentId,
    required String pageId,
    required File source,
  }) async {
    final rawExt = p.extension(source.path).replaceAll('.', '').toLowerCase();
    final ext = rawExt.isEmpty ? 'jpg' : rawExt;
    final dir = Directory(p.join(root.path, 'documents', documentId));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final fileName = '${pageId}_original.$ext';
    final target = File(p.join(dir.path, fileName));
    await source.copy(target.path);
    return 'documents/$documentId/$fileName';
  }

  Future<String> importOriginalBytes({
    required String documentId,
    required String pageId,
    required List<int> bytes,
    String ext = 'png',
  }) {
    final clean = ext.replaceAll('.', '').toLowerCase();
    final finalExt = clean.isEmpty ? 'png' : clean;
    return _writeBytes(documentId, '${pageId}_original.$finalExt', bytes);
  }

  Future<String> writeEdited({
    required String documentId,
    required String pageId,
    required List<int> bytes,
    String ext = 'jpg',
  }) {
    final clean = ext.replaceAll('.', '').toLowerCase();
    final finalExt = clean.isEmpty ? 'jpg' : clean;
    return _writeBytes(documentId, '${pageId}_edited.$finalExt', bytes);
  }

  Future<String> writeThumbnail({
    required String documentId,
    required String pageId,
    required List<int> bytes,
  }) => _writeBytes(documentId, '${pageId}_thumb.png', bytes);

  Future<String> _writeBytes(String documentId, String fileName, List<int> bytes) async {
    final dir = Directory(p.join(root.path, 'documents', documentId));
    if (!await dir.exists()) await dir.create(recursive: true);
    final target = File(p.join(dir.path, fileName));
    await target.writeAsBytes(bytes, flush: true);
    return 'documents/$documentId/$fileName';
  }

  File resolve(String relativePath) {
    if (relativePath.isEmpty) {
      throw ArgumentError.value(relativePath, 'relativePath', 'Path cannot be empty');
    }
    if (relativePath.contains('..')) {
      throw ArgumentError.value(relativePath, 'relativePath', 'Path traversal is not allowed');
    }
    if (p.isAbsolute(relativePath) ||
        relativePath.startsWith('/') ||
        relativePath.startsWith(r'\') ||
        RegExp(r'^[a-zA-Z]:').hasMatch(relativePath)) {
      throw ArgumentError.value(relativePath, 'relativePath', 'Absolute paths are not allowed');
    }
    final normalized = p.posix.normalize(relativePath.replaceAll(r'\', '/'));
    if (normalized.startsWith('..') || normalized.contains('..') || normalized.startsWith('/')) {
      throw ArgumentError.value(relativePath, 'relativePath', 'Invalid relative path');
    }
    final segments = normalized.split('/');
    return File(p.join(root.path, p.joinAll(segments)));
  }

  Future<void> deletePageFiles(String documentId, String pageId) async {
    final dir = Directory(p.join(root.path, 'documents', documentId));
    if (!await dir.exists()) return;
    final entities = await dir.list().toList();
    for (final entity in entities) {
      if (entity is File) {
        final name = p.basename(entity.path);
        if (name.startsWith('${pageId}_original.') ||
            name.startsWith('${pageId}_edited.') ||
            name.startsWith('${pageId}_thumb.')) {
          await entity.delete();
        }
      }
    }
  }

  Future<void> deleteDocumentDir(String documentId) async {
    final dir = Directory(p.join(root.path, 'documents', documentId));
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  Future<int> documentSizeBytes(String documentId) async {
    final dir = Directory(p.join(root.path, 'documents', documentId));
    if (!await dir.exists()) return 0;
    var total = 0;
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        total += await entity.length();
      }
    }
    return total;
  }

  Future<int> countFiles() async {
    if (!await root.exists()) return 0;
    var count = 0;
    await for (final entity in root.list(recursive: true)) {
      if (entity is File) {
        count++;
      }
    }
    return count;
  }

  Future<List<String>> listDocumentDirIds() async {
    final docsDir = Directory(p.join(root.path, 'documents'));
    if (!await docsDir.exists()) return const [];
    final ids = <String>[];
    await for (final entity in docsDir.list()) {
      if (entity is Directory) {
        ids.add(p.basename(entity.path));
      }
    }
    return ids;
  }
}
