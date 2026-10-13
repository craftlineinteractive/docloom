import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:docloom/core/db/app_database.dart';
import 'package:docloom/core/errors/app_exception.dart';
import 'package:docloom/features/documents/data/sqlite_document_repository.dart';
import 'package:docloom/features/documents/domain/new_page.dart';
import 'package:docloom/features/folders/data/sqlite_folder_repository.dart';
import 'package:docloom/features/home/application/library_actions.dart';
import 'package:docloom/features/trash/data/sqlite_trash_repository.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  late AppDatabase db;
  late SqliteFolderRepository folderRepo;
  late SqliteDocumentRepository docRepo;
  late SqliteTrashRepository trashRepo;
  late LibraryActions actions;

  setUp(() async {
    db = await AppDatabase.open(factory: databaseFactoryFfi, path: inMemoryDatabasePath);
    folderRepo = SqliteFolderRepository(db);
    docRepo = SqliteDocumentRepository(db);
    trashRepo = SqliteTrashRepository(db);
    actions = LibraryActions(folderRepo: folderRepo, docRepo: docRepo, trashRepo: trashRepo);
  });

  tearDown(() => db.close());

  group('LibraryActions - Document CRUD', () {
    test('renameDocument renames document or throws on empty', () async {
      await docRepo.createWithPages(id: 'd1', name: 'Original', pages: const [NewPage(id: 'p1', originalPath: 'p1')]);
      await actions.renameDocument(id: 'd1', name: 'Renamed');
      final updated = await docRepo.getById('d1');
      expect(updated?.name, 'Renamed');
      expect(() => actions.renameDocument(id: 'd1', name: '  '), throwsA(isA<ValidationException>()));
    });

    test('toggleFavorite toggles favorite flag', () async {
      await docRepo.createWithPages(id: 'd2', name: 'Doc Fav', pages: const [NewPage(id: 'p2', originalPath: 'p2')]);
      await actions.toggleFavorite(id: 'd2', currentIsFavorite: false);
      var doc = await docRepo.getById('d2');
      expect(doc?.isFavorite, isTrue);

      await actions.toggleFavorite(id: 'd2', currentIsFavorite: true);
      doc = await docRepo.getById('d2');
      expect(doc?.isFavorite, isFalse);
    });

    test('moveDocument moves between root and folder', () async {
      final f = await folderRepo.create(name: 'Contracts');
      await docRepo.createWithPages(id: 'd3', name: 'Contract A', pages: const [NewPage(id: 'p3', originalPath: 'p3')]);

      await actions.moveDocument(id: 'd3', targetFolderId: f.id);
      var doc = await docRepo.getById('d3');
      expect(doc?.folderId, f.id);

      await actions.moveDocument(id: 'd3', targetFolderId: null);
      doc = await docRepo.getById('d3');
      expect(doc?.folderId, isNull);
    });

    test('deleteDocument and undoDeleteDocument restores document', () async {
      await docRepo.createWithPages(id: 'd4', name: 'Doc Trash', pages: const [NewPage(id: 'p4', originalPath: 'p4')]);
      await actions.deleteDocument('d4');
      expect(await docRepo.getById('d4'), isNull);

      final result = await actions.undoDeleteDocument('d4');
      expect(result.restoredToRoot, isFalse);
      expect(await docRepo.getById('d4'), isNotNull);

      // When folder is trashed, document restores to root with restoredToRoot = true
      final f = await folderRepo.create(name: 'Temp Folder');
      await docRepo.createWithPages(id: 'd5', name: 'Doc in Folder', folderId: f.id, pages: const [NewPage(id: 'p5', originalPath: 'p5')]);
      await actions.deleteDocument('d5');
      await folderRepo.moveToTrash(f.id);

      final resFolder = await actions.undoDeleteDocument('d5');
      expect(resFolder.restoredToRoot, isTrue);
      final docRestored = await docRepo.getById('d5');
      expect(docRestored?.folderId, isNull);
    });
  });
}
