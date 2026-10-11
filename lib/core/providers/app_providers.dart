import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/documents/data/sqlite_document_repository.dart';
import '../../features/documents/domain/document_repository.dart';
import '../../features/folders/data/sqlite_folder_repository.dart';
import '../../features/folders/domain/folder_repository.dart';
import '../../features/trash/application/trash_service.dart';
import '../../features/trash/data/sqlite_trash_repository.dart';
import '../../features/trash/domain/trash_repository.dart';
import '../db/app_database.dart';
import '../ids/id_generator.dart';
import '../storage/document_file_store.dart';
import '../time/clock.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('override in main');
});

final fileStoreProvider = Provider<DocumentFileStore>((ref) {
  throw UnimplementedError('override in main');
});

final clockProvider = Provider<Clock>((ref) => systemClock);

final idGeneratorProvider = Provider<IdGenerator>((ref) => newId);

final folderRepositoryProvider = Provider<FolderRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final clock = ref.watch(clockProvider);
  final idGenerator = ref.watch(idGeneratorProvider);
  return SqliteFolderRepository(
    db,
    clock: clock,
    idGenerator: idGenerator,
  );
});

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final clock = ref.watch(clockProvider);
  final idGenerator = ref.watch(idGeneratorProvider);
  return SqliteDocumentRepository(
    db,
    clock: clock,
    idGenerator: idGenerator,
  );
});

final trashRepositoryProvider = Provider<TrashRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final clock = ref.watch(clockProvider);
  final idGenerator = ref.watch(idGeneratorProvider);
  return SqliteTrashRepository(
    db,
    clock: clock,
    idGenerator: idGenerator,
  );
});

final trashServiceProvider = Provider<TrashService>((ref) {
  final trashRepo = ref.watch(trashRepositoryProvider);
  final fileStore = ref.watch(fileStoreProvider);
  final clock = ref.watch(clockProvider);
  return TrashService(
    trashRepo,
    fileStore,
    clock: clock,
  );
});
