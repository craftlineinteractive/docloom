import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:docloom/core/db/app_database.dart';
import 'package:docloom/core/errors/app_exception.dart';
import 'package:docloom/features/documents/data/sqlite_document_repository.dart';
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
  var currentTime = DateTime.utc(2026, 10, 12, 10, 0);
  DateTime clock() => currentTime;

  setUp(() async {
    db = await AppDatabase.open(factory: databaseFactoryFfi, path: inMemoryDatabasePath);
    folderRepo = SqliteFolderRepository(db, clock: clock);
    docRepo = SqliteDocumentRepository(db, clock: clock);
    trashRepo = SqliteTrashRepository(db, clock: clock);
    actions = LibraryActions(folderRepo: folderRepo, docRepo: docRepo, trashRepo: trashRepo);
  });

  tearDown(() => db.close());

  group('LibraryActions - Folder CRUD', () {
    test('createFolder creates folder with trimmed name', () async {
      final f = await actions.createFolder(name: '  Invoices  ', colorIndex: 2);
      expect(f.name, 'Invoices');
      expect(f.colorIndex, 2);
    });

    test('createFolder throws on empty or whitespace name', () async {
      expect(() => actions.createFolder(name: '   '), throwsA(isA<ValidationException>()));
    });

    test('renameFolder renames folder or throws on empty', () async {
      final f = await actions.createFolder(name: 'Work');
      await actions.renameFolder(id: f.id, name: 'Personal');
      final updated = await folderRepo.getById(f.id);
      expect(updated?.name, 'Personal');
      expect(() => actions.renameFolder(id: f.id, name: ''), throwsA(isA<ValidationException>()));
    });

    test('setFolderColor updates colorIndex and bumps updated_at', () async {
      final f = await actions.createFolder(name: 'Receipts', colorIndex: 0);
      currentTime = currentTime.add(const Duration(minutes: 5));
      await actions.setFolderColor(id: f.id, colorIndex: 3);
      final updated = await folderRepo.getById(f.id);
      expect(updated?.colorIndex, 3);
      expect(updated?.updatedAt, currentTime);
    });

    test('setFolderColor throws NotFoundException on non-existent or trashed folder', () async {
      expect(() => actions.setFolderColor(id: 'non-existent', colorIndex: 1), throwsA(isA<NotFoundException>()));
      final f = await actions.createFolder(name: 'Temp');
      await actions.deleteFolder(f.id);
      expect(() => actions.setFolderColor(id: f.id, colorIndex: 2), throwsA(isA<NotFoundException>()));
    });

    test('deleteFolder moves to trash and undoDeleteFolder restores it', () async {
      final f = await actions.createFolder(name: 'Tax');
      await actions.deleteFolder(f.id);
      expect(await folderRepo.getById(f.id), isNull);
      await actions.undoDeleteFolder(f.id);
      expect(await folderRepo.getById(f.id), isNotNull);
    });
  });
}
