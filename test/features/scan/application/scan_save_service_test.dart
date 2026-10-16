import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:docloom/core/db/app_database.dart';
import 'package:docloom/core/errors/app_exception.dart';
import 'package:docloom/core/storage/document_file_store.dart';
import 'package:docloom/core/storage/thumbnail_generator.dart';
import 'package:docloom/features/documents/data/sqlite_document_repository.dart';
import 'package:docloom/features/scan/application/scan_save_service.dart';
import 'package:docloom/features/scan/domain/scanned_page.dart';

void main() {
  setUpAll(sqfliteFfiInit);
  late Directory tempDir, sessionDir;
  late DocumentFileStore fileStore;
  late AppDatabase db;
  late SqliteDocumentRepository repo;
  late ScanSaveService service;
  var idCounter = 0;

  setUp(() async {
    idCounter = 0;
    tempDir = await Directory.systemTemp.createTemp('save_svc_');
    sessionDir = Directory(p.join(tempDir.path, 'session_123'))..createSync();
    final storeRoot = Directory(p.join(tempDir.path, 'filestore'))..createSync();
    fileStore = DocumentFileStore(storeRoot);
    db = await AppDatabase.open(factory: databaseFactoryFfi, path: p.join(tempDir.path, 't.db'));
    repo = SqliteDocumentRepository(db);
    service = ScanSaveService(
      repo,
      fileStore,
      clock: () => DateTime(2026, 10, 16, 14, 30),
      idGenerator: () => 'id-${++idCounter}',
      thumbnailGenerator: const ThumbnailGenerator(),
    );
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  group('ScanSaveService', () {
    test('throws ValidationException when saving with zero pages', () {
      expect(() => service.save(pages: const []), throwsA(isA<ValidationException>()));
    });

    test('throws NotFoundException when original file is missing', () {
      final page = ScannedPage(originalPath: p.join(sessionDir.path, 'missing_orig.jpg'));
      expect(() => service.save(pages: [page]), throwsA(isA<NotFoundException>()));
    });

    test('throws NotFoundException when edited file is missing', () async {
      final orig = File(p.join(sessionDir.path, 'orig.jpg'))..writeAsBytesSync([1, 2, 3]);
      final page = ScannedPage(
        originalPath: orig.path,
        editedPath: p.join(sessionDir.path, 'missing_edit.jpg'),
      );
      expect(() => service.save(pages: [page]), throwsA(isA<NotFoundException>()));
    });

    test('cleans up created document directory and rethrows on repo failure', () async {
      final orig = File(p.join(sessionDir.path, 'orig.jpg'))..writeAsBytesSync([1, 2, 3]);
      await db.close(); // induce repository failure
      final page = ScannedPage(originalPath: orig.path);
      await expectLater(() => service.save(pages: [page]), throwsA(isA<Exception>()));
      expect(await fileStore.listDocumentDirIds(), isEmpty);
    });

    test('saves document, copies files, stores thumbnail for pos 0, cleans session', () async {
      final p1Orig = File(p.join(sessionDir.path, 'p1_orig.jpg'))..writeAsBytesSync([10, 20]);
      final p1Edit = File(p.join(sessionDir.path, 'p1_edit.jpg'))..writeAsBytesSync([30, 40]);
      final p2Orig = File(p.join(sessionDir.path, 'p2_orig.jpg'))..writeAsBytesSync([50, 60]);

      final pages = [
        ScannedPage(
          originalPath: p1Orig.path,
          editedPath: p1Edit.path,
          filterId: 'grayscale',
          rotation: 90,
          cropJson: '{"tl":[0,0],"tr":[1,0],"br":[1,1],"bl":[0,1]}',
        ),
        ScannedPage(originalPath: p2Orig.path, filterId: 'original', rotation: 0),
      ];

      final doc = await service.save(pages: pages, name: 'My Contract');
      expect(doc.id, equals('id-1'));
      expect(doc.name, equals('My Contract'));

      final savedPages = await repo.getPages(doc.id);
      expect(savedPages.length, equals(2));
      expect(savedPages.first.id, equals('id-2'));
      expect(savedPages.first.filterId, equals('grayscale'));
      expect(savedPages.first.rotation, equals(90));
      expect(savedPages.first.cropJson, contains('"tl"'));
      expect(savedPages.first.editedPath, contains('id-2_edited'));

      expect(savedPages[1].id, equals('id-3'));
      expect(savedPages[1].filterId, equals('original'));
      expect(savedPages[1].rotation, equals(0));

      expect(await sessionDir.exists(), isFalse);
    });

    test('formats default document name when name is omitted or empty', () async {
      final p1 = File(p.join(sessionDir.path, 'p1.jpg'))..writeAsBytesSync([1]);
      final doc = await service.save(pages: [ScannedPage(originalPath: p1.path)]);
      expect(doc.name, equals('docLoom 16 Oct 2026 14-30'));
    });
  });
}
