import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:docloom/core/db/app_database.dart';
import 'package:docloom/core/errors/app_exception.dart';
import 'package:docloom/features/documents/data/sqlite_document_repository.dart';
import 'package:docloom/features/documents/domain/new_page.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  late AppDatabase db;
  late SqliteDocumentRepository repository;
  late DateTime fakeTime;

  DateTime clock() => fakeTime;

  setUp(() async {
    fakeTime = DateTime.utc(2026, 10, 11, 12, 0, 0);
    db = await AppDatabase.open(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    repository = SqliteDocumentRepository(db, clock: clock);
  });

  tearDown(() => db.close());

  test('moveManyToTrash moves active documents to trash in one transaction', () async {
    final d1 = await repository.createWithPages(id: 'd1', name: 'Doc 1', pages: const [NewPage(id: 'p1', originalPath: 'p1.jpg')]);
    final d2 = await repository.createWithPages(id: 'd2', name: 'Doc 2', pages: const [NewPage(id: 'p2', originalPath: 'p2.jpg')]);

    await repository.moveManyToTrash([d1.id, d2.id]);

    expect(await repository.getById('d1'), isNull);
    expect(await repository.getById('d2'), isNull);
  });

  test('moveManyToTrash rolls back all changes if any id is not found (all-or-nothing)', () async {
    final d1 = await repository.createWithPages(id: 'd1', name: 'Doc 1', pages: const [NewPage(id: 'p1', originalPath: 'p1.jpg')]);
    final d2 = await repository.createWithPages(id: 'd2', name: 'Doc 2', pages: const [NewPage(id: 'p2', originalPath: 'p2.jpg')]);

    expect(
      () => repository.moveManyToTrash([d1.id, 'missing-id', d2.id]),
      throwsA(isA<NotFoundException>()),
    );

    // Rollback check: d1 must still be active and not trashed
    final doc1 = await repository.getById('d1');
    expect(doc1, isNotNull);
    expect(doc1!.name, equals('Doc 1'));

    final doc2 = await repository.getById('d2');
    expect(doc2, isNotNull);
    expect(doc2!.name, equals('Doc 2'));
  });

  test('moveManyToTrash ignores already trashed documents preserving their original deleted_at', () async {
    final d1 = await repository.createWithPages(id: 'd1', name: 'Doc 1', pages: const [NewPage(id: 'p1', originalPath: 'p1.jpg')]);
    final d2 = await repository.createWithPages(id: 'd2', name: 'Doc 2', pages: const [NewPage(id: 'p2', originalPath: 'p2.jpg')]);

    final initialTimeMs = fakeTime.millisecondsSinceEpoch;
    await repository.moveToTrash(d1.id);

    // Advance clock by 1 hour
    fakeTime = fakeTime.add(const Duration(hours: 1));
    final newTimeMs = fakeTime.millisecondsSinceEpoch;

    await repository.moveManyToTrash([d1.id, d2.id]);

    final row1 = (await db.db.query('documents', where: 'id = ?', whereArgs: [d1.id])).first;
    final row2 = (await db.db.query('documents', where: 'id = ?', whereArgs: [d2.id])).first;

    // d1's deleted_at was preserved
    expect(row1['deleted_at'], equals(initialTimeMs));
    // d2 was newly trashed with the updated time
    expect(row2['deleted_at'], equals(newTimeMs));
  });

  test('moveManyToTrash with empty list is a no-op', () async {
    await repository.moveManyToTrash(const []);
  });
}
