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

  test('addPages appends pages at end and bumps document updated_at', () async {
    final doc = await repository.createWithPages(
      id: 'd1',
      name: 'Doc',
      pages: const [NewPage(id: 'p0', originalPath: 'p0.jpg')],
    );
    fakeTime = fakeTime.add(const Duration(minutes: 10));

    await repository.addPages('d1', const [
      NewPage(id: 'p1', originalPath: 'p1.jpg'),
      NewPage(id: 'p2', originalPath: 'p2.jpg'),
    ]);

    final pages = await repository.getPages('d1');
    expect(pages.length, equals(3));
    expect(pages.map((p) => p.position).toList(), equals([0, 1, 2]));

    final updatedDoc = await repository.getById('d1');
    expect(updatedDoc?.updatedAt, equals(fakeTime));
    expect(updatedDoc?.updatedAt.isAfter(doc.updatedAt), isTrue);
  });

  test('deletePage renumbers remaining pages contiguously', () async {
    await repository.createWithPages(
      id: 'd2',
      name: 'Multi-page',
      pages: const [
        NewPage(id: 'p0', originalPath: 'p0.jpg'),
        NewPage(id: 'p1', originalPath: 'p1.jpg'),
        NewPage(id: 'p2', originalPath: 'p2.jpg'),
      ],
    );

    final deleted = await repository.deletePage('p1');
    expect(deleted.id, equals('p1'));

    final remaining = await repository.getPages('d2');
    expect(remaining.length, equals(2));
    expect(remaining[0].id, equals('p0'));
    expect(remaining[0].position, equals(0));
    expect(remaining[1].id, equals('p2'));
    expect(remaining[1].position, equals(1));
  });

  test('deleting the last page is rejected with ValidationException', () async {
    await repository.createWithPages(
      id: 'd3',
      name: 'Single',
      pages: const [NewPage(id: 'single-p', originalPath: 's.jpg')],
    );

    expect(() => repository.deletePage('single-p'), throwsA(isA<ValidationException>()));
  });

  test('reorderPages renumbers positions and rejects mismatching ids', () async {
    await repository.createWithPages(
      id: 'd4',
      name: 'Reorder Doc',
      pages: const [
        NewPage(id: 'p0', originalPath: 'p0.jpg'),
        NewPage(id: 'p1', originalPath: 'p1.jpg'),
        NewPage(id: 'p2', originalPath: 'p2.jpg'),
      ],
    );

    expect(() => repository.reorderPages('d4', ['p0', 'wrong-id']), throwsA(isA<ValidationException>()));
    expect(() => repository.reorderPages('d4', ['p0', 'p1']), throwsA(isA<ValidationException>()));

    await repository.reorderPages('d4', ['p2', 'p0', 'p1']);
    final pages = await repository.getPages('d4');
    expect(pages[0].id, equals('p2'));
    expect(pages[0].position, equals(0));
    expect(pages[1].id, equals('p0'));
    expect(pages[1].position, equals(1));
    expect(pages[2].id, equals('p1'));
    expect(pages[2].position, equals(2));
  });
}
