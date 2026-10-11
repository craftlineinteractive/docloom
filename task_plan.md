# Task Plan: docLoom Phase 2A (Database Foundation Only)

**Goal:** Implement SQLite database foundation, schema v1, core domain models, utilities (clock, id generator, exceptions), and full FFI-based integration & domain unit tests for docLoom.

## Status Summary
- **Current Phase:** Phase 2A - Database Foundation Only
- **Status:** In Progress

---

## Planned File List (Create Only These)

### 1. Packages
- Direct: `sqflite`, `path_provider`, `path`, `uuid`
- Dev: `sqflite_common_ffi`

### 2. Core Utilities & Errors (`lib/core/`)
- `lib/core/errors/app_exception.dart`
  - `class AppException implements Exception { final String message; }`
  - `class NotFoundException extends AppException`
  - `class ValidationException extends AppException`
- `lib/core/time/clock.dart`
  - `typedef Clock = DateTime Function();`
  - `DateTime systemClock() => DateTime.now().toUtc();`
- `lib/core/ids/id_generator.dart`
  - `typedef IdGenerator = String Function();`
  - `String newId() => const Uuid().v4();`

### 3. Database & Schema (`lib/core/db/`)
- `lib/core/db/schema.dart`
  - Exact SQL statements (3 tables: folders, documents, pages; 4 indexes) as `const List<String> schemaV1`
- `lib/core/db/app_database.dart`
  - `class AppDatabase` with `final Database db`, `static const version = 1`
  - `static Future<AppDatabase> open({required DatabaseFactory factory, required String path})`
  - `Future<void> close()`
  - `onConfigure`: PRAGMA foreign_keys = ON
  - `onCreate`: executes all statements in `schemaV1`
  - `onUpgrade`: throws `UnsupportedError` with migration explanation

### 4. Domain Models (`lib/features/.../domain/`)
- `lib/features/folders/domain/folder.dart`
  - Immutable, const constructor, `fromMap`/`toMap`, `copyWith`, `withDeletedAt(DateTime?)`
- `lib/features/folders/domain/folder_summary.dart`
  - Immutable, const constructor, `folder`, `itemCount`
- `lib/features/documents/domain/document.dart`
  - Immutable, const constructor, `fromMap`/`toMap`, `copyWith`
  - Explicit mutators: `withDeletedAt(DateTime?)`, `withFolderId(String?)`, `withNote(String?)`
- `lib/features/documents/domain/scan_page.dart`
  - Immutable, const constructor, `fromMap`/`toMap`, `copyWith`, `withEditedPath(String?)`
  - Getter: `displayPath => editedPath ?? originalPath`
- `lib/features/documents/domain/document_summary.dart`
  - Immutable, const constructor, `document`, `pageCount`, `coverPath?`
- `lib/features/documents/domain/new_page.dart`
  - Immutable, const constructor: `id`, `originalPath`
- `lib/features/documents/domain/document_sort.dart`
  - `enum DocumentSort { modifiedDesc, modifiedAsc, nameAsc, nameDesc }`

### 5. Tests (`test/core/db/` & `test/features/.../domain/`)
- `test/core/db/app_database_test.dart`
  - `sqfliteFfiInit()` and `databaseFactoryFfi` with `inMemoryDatabasePath`
  - Tables & indexes exist check (`sqlite_master`)
  - `PRAGMA foreign_keys` returns 1
  - Foreign key constraint failure on non-existent document page insert
  - Cascade deletion: deleting document deletes related pages
- `test/features/folders/domain/folder_test.dart`
  - `toMap`/`fromMap` round-trip
  - `withDeletedAt(null)` clears value
- `test/features/documents/domain/document_test.dart`
  - `toMap`/`fromMap` round-trip (including nulls, `isFavorite` bool to 0/1)
  - `withDeletedAt(null)`, `withFolderId(null)`, `withNote(null)`
- `test/features/documents/domain/scan_page_test.dart`
  - `toMap`/`fromMap` round-trip
  - `displayPath` getter behavior
  - `withEditedPath(null)`
- `test/features/documents/domain/document_summary_test.dart`
  - Verification of summary objects

---

## Step-by-Step Execution Plan
- [x] Step 1: Add dependencies via `flutter pub add` <!-- id: 50 -->
- [x] Step 2: Implement core errors and utilities (`app_exception.dart`, `clock.dart`, `id_generator.dart`) <!-- id: 51 -->
- [x] Step 3: Implement database schema (`schema.dart`) <!-- id: 52 -->
- [x] Step 4: Implement domain models (`folder.dart`, `folder_summary.dart`, `document.dart`, `scan_page.dart`, `document_summary.dart`, `new_page.dart`, `document_sort.dart`) <!-- id: 53 -->
- [x] Step 5: Implement `AppDatabase` (`app_database.dart`) <!-- id: 54 -->
- [x] Step 6: Implement database FFI tests and model unit tests <!-- id: 55 -->
- [x] Step 7: Verify all files <= 150 lines, no magic numbers, run `flutter analyze` and `flutter test` <!-- id: 56 -->

---

## Phase 2C: File Storage + Trash Service + Providers + Startup + Debug Check Screen

### Planned Files
1. `lib/core/constants/app_config.dart`
   - `trashRetention = Duration(days: 30)`
2. `lib/core/storage/document_file_store.dart`
   - `DocumentFileStore(Directory root)`
   - `importOriginal`, `writeEdited`, `resolve`, `deletePageFiles`, `deleteDocumentDir`, `documentSizeBytes`, `countFiles`
3. `lib/features/trash/application/trash_service.dart`
   - `TrashService(TrashRepository trash, DocumentFileStore files, {Clock clock = systemClock})`
   - `purgeExpired`, `deleteDocumentForever`, `deleteFolderForever`, `emptyTrash`
4. `lib/core/providers/app_providers.dart`
   - Riverpod 3 providers: `appDatabaseProvider`, `fileStoreProvider`, `clockProvider`, `idGeneratorProvider`, `folderRepositoryProvider`, `documentRepositoryProvider`, `trashRepositoryProvider`, `trashServiceProvider`
5. `lib/app/bootstrap.dart` & `lib/main.dart`
   - `bootstrap()`: opens DB, configures `DocumentFileStore`, returns overrides
   - `main.dart`: initializes widgets, awaits `bootstrap()`, runs `DocLoomApp`, runs `trashService.purgeExpired()` post-first-frame inside try/catch
6. `lib/features/dev/db_check_screen.dart` & widgets
   - Route `/dev/db-check` (only when `kDebugMode`)
   - Link button in `ComponentGalleryScreen`
   - `db_check_screen.dart`, `db_check_action_buttons.dart`, `db_check_stats_card.dart`
7. Tests
   - `test/core/storage/document_file_store_test.dart`
   - `test/integration/storage_lifecycle_test.dart`
   - `test/core/providers/app_providers_test.dart`
   - Fix `test/app_smoke_test.dart` with in-memory overrides

### Execution Checklist
- [ ] Task 1: Create `AppConfig` with `trashRetention` <!-- id: 63 -->
- [ ] Task 2: Implement `DocumentFileStore` with path traversal rejection and relative forward-slash paths <!-- id: 64 -->
- [ ] Task 3: Implement `TrashService` calling repository first, then deleting file directories <!-- id: 65 -->
- [ ] Task 4: Implement Riverpod 3 `app_providers.dart` <!-- id: 66 -->
- [ ] Task 5: Implement `bootstrap.dart`, update `main.dart`, and update `app_smoke_test.dart` <!-- id: 67 -->
- [ ] Task 6: Implement `/dev/db-check` screen and link from `ComponentGalleryScreen` (all files <= 150 lines) <!-- id: 68 -->
- [ ] Task 7: Create unit and integration tests (file store, trash service lifecycle with fake clock, provider wiring) <!-- id: 69 -->
- [ ] Task 8: Verify line limits, `flutter analyze`, `flutter test`, and real device verification <!-- id: 70 -->

