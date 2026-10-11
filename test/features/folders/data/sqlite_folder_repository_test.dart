import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:docloom/core/db/app_database.dart';
import 'package:docloom/core/errors/app_exception.dart';
import 'package:docloom/features/folders/data/sqlite_folder_repository.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  late AppDatabase db;
  late SqliteFolderRepository repository;
  late DateTime fakeTime;

  DateTime clock() => fakeTime;

  setUp(() async {
    fakeTime = DateTime.utc(2026, 10, 11, 12, 0, 0);
    db = await AppDatabase.open(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    repository = SqliteFolderRepository(db, clock: clock);
  });

  tearDown(() => db.close());

  test('create trims the name and generates id', () async {
    final folder = await repository.create(name: '  Personal IDs  ', colorIndex: 2);
    expect(folder.name, equals('Personal IDs'));
    expect(folder.colorIndex, equals(2));
    expect(folder.createdAt, equals(fakeTime));
  });

  test('empty name is rejected with ValidationException', () async {
    expect(() => repository.create(name: '   '), throwsA(isA<ValidationException>()));
  });

  test('rename updates name and updated_at with trimming', () async {
    final folder = await repository.create(name: 'Work');
    fakeTime = fakeTime.add(const Duration(minutes: 5));
    await repository.rename(folder.id, '  Archive  ');

    final updated = await repository.getById(folder.id);
    expect(updated?.name, equals('Archive'));
    expect(updated?.updatedAt, equals(fakeTime));
  });

  test('listActive excludes trashed and sorts by name ascending case-insensitive', () async {
    await repository.create(name: 'beta');
    await repository.create(name: 'Alpha');
    final trashed = await repository.create(name: 'gamma');
    await repository.moveToTrash(trashed.id);

    final list = await repository.listActive();
    expect(list.map((s) => s.folder.name).toList(), equals(['Alpha', 'beta']));
  });

  test('itemCount counts only active documents in the folder', () async {
    final folder = await repository.create(name: 'Docs');
    await db.db.insert('documents', {
      'id': 'd1',
      'folder_id': folder.id,
      'name': 'Doc 1',
      'created_at': fakeTime.millisecondsSinceEpoch,
      'updated_at': fakeTime.millisecondsSinceEpoch,
    });
    await db.db.insert('documents', {
      'id': 'd2',
      'folder_id': folder.id,
      'name': 'Doc 2',
      'created_at': fakeTime.millisecondsSinceEpoch,
      'updated_at': fakeTime.millisecondsSinceEpoch,
      'deleted_at': fakeTime.millisecondsSinceEpoch,
    });

    final list = await repository.listActive();
    expect(list.first.itemCount, equals(1));
  });

  test('moveToTrash sets deleted_at on folder only and leaves documents untouched', () async {
    final folder = await repository.create(name: 'Invoices');
    await db.db.insert('documents', {
      'id': 'd3',
      'folder_id': folder.id,
      'name': 'Active Invoice',
      'created_at': fakeTime.millisecondsSinceEpoch,
      'updated_at': fakeTime.millisecondsSinceEpoch,
    });

    await repository.moveToTrash(folder.id);
    expect(await repository.getById(folder.id), isNull);

    final docRow = await db.db.query('documents', where: 'id = ?', whereArgs: ['d3']);
    expect(docRow.first['deleted_at'], isNull);
  });
}
