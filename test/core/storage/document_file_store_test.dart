import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/core/storage/document_file_store.dart';

void main() {
  late Directory tempRoot;
  late DocumentFileStore fileStore;

  setUp(() async {
    tempRoot = await Directory.systemTemp.createTemp('file_store_test_');
    fileStore = DocumentFileStore(tempRoot);
  });

  tearDown(() async {
    if (await tempRoot.exists()) {
      await tempRoot.delete(recursive: true);
    }
  });

  test('importOriginal copies file, preserves extension, and returns forward-slash path', () async {
    final sourceFile = File('${tempRoot.path}/source.PNG');
    await sourceFile.writeAsString('test content');

    final relPath = await fileStore.importOriginal(
      documentId: 'doc1',
      pageId: 'page1',
      source: sourceFile,
    );

    expect(relPath, 'documents/doc1/page1_original.png');
    final resolved = fileStore.resolve(relPath);
    expect(await resolved.exists(), isTrue);
    expect(await resolved.readAsString(), 'test content');
  });

  test('importOriginal uses jpg default if source has no extension', () async {
    final sourceFile = File('${tempRoot.path}/source_no_ext');
    await sourceFile.writeAsString('no ext');

    final relPath = await fileStore.importOriginal(
      documentId: 'doc1',
      pageId: 'page1',
      source: sourceFile,
    );

    expect(relPath, 'documents/doc1/page1_original.jpg');
  });

  test('writeEdited writes bytes and returns forward-slash relative path', () async {
    final relPath = await fileStore.writeEdited(
      documentId: 'doc1',
      pageId: 'page1',
      bytes: [1, 2, 3, 4],
      ext: 'jpg',
    );

    expect(relPath, 'documents/doc1/page1_edited.jpg');
    final resolved = fileStore.resolve(relPath);
    expect(await resolved.exists(), isTrue);
    expect(await resolved.readAsBytes(), [1, 2, 3, 4]);
  });

  test('resolve rejects traversal and absolute paths', () {
    expect(() => fileStore.resolve('../etc/passwd'), throwsArgumentError);
    expect(() => fileStore.resolve('documents/../../x'), throwsArgumentError);
    expect(() => fileStore.resolve('/absolute/path'), throwsArgumentError);
    expect(() => fileStore.resolve(r'C:\Windows\System32'), throwsArgumentError);
    expect(() => fileStore.resolve(''), throwsArgumentError);
  });

  test('deletePageFiles removes both original and edited files for that page', () async {
    await fileStore.writeEdited(documentId: 'doc1', pageId: 'p1', bytes: [1]);
    await fileStore.writeEdited(documentId: 'doc1', pageId: 'p2', bytes: [2]);

    await fileStore.deletePageFiles('doc1', 'p1');

    final p1File = fileStore.resolve('documents/doc1/p1_edited.jpg');
    final p2File = fileStore.resolve('documents/doc1/p2_edited.jpg');
    expect(await p1File.exists(), isFalse);
    expect(await p2File.exists(), isTrue);
  });

  test('deleteDocumentDir deletes directory and is no-op if missing', () async {
    await fileStore.writeEdited(documentId: 'doc1', pageId: 'p1', bytes: [1]);
    expect(await fileStore.resolve('documents/doc1/p1_edited.jpg').exists(), isTrue);

    await fileStore.deleteDocumentDir('doc1');
    expect(await fileStore.resolve('documents/doc1/p1_edited.jpg').exists(), isFalse);

    // No-op if missing
    await fileStore.deleteDocumentDir('missing_doc');
  });

  test('documentSizeBytes and countFiles compute correct values', () async {
    expect(await fileStore.documentSizeBytes('doc1'), 0);
    expect(await fileStore.countFiles(), 0);

    await fileStore.writeEdited(documentId: 'doc1', pageId: 'p1', bytes: [1, 2, 3]);
    await fileStore.writeEdited(documentId: 'doc1', pageId: 'p2', bytes: [4, 5]);

    expect(await fileStore.documentSizeBytes('doc1'), 5);
    expect(await fileStore.countFiles(), 2);
  });
}
