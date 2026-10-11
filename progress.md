# Progress Log: docLoom Phase 1A

## Initial State
- Initialized empty flutter project.
- Verified `flutter analyze` runs cleanly.
- Verified Android physical device `KB2005` available.
- Verified font assets exist in `assets/fonts/`.

## Completed Work
- Added `flutter_riverpod`, `go_router`, and `lucide_icons_flutter` packages to `pubspec.yaml`.
- Configured Inter font family with Regular (400), Medium (500), and SemiBold (600) assets in `pubspec.yaml`.
- Implemented design token files in `lib/core/theme/`:
  - `app_colors.dart`
  - `app_spacing.dart`
  - `app_radius.dart`
  - `app_shadows.dart`
  - `app_typography.dart`
  - `app_theme.dart`
- Built application shell:
  - `lib/app/router/routes.dart`
  - `lib/features/home/presentation/home_screen.dart`
  - `lib/app/router/app_router.dart`
  - `lib/app/app.dart`
  - `lib/main.dart`
- Updated `test/widget_test.dart` to smoke test `DocLoomApp`.
- Verified all file line counts are <= 150 lines (max 55 lines).
- Confirmed no hex colors, magic numbers, or inline TextStyles outside `lib/core/theme/`.
- Verified `flutter analyze`: zero issues.
- Verified `flutter test`: all tests passed.
- Verified `flutter build apk --debug`: compiled successfully.

## Phase 1C Completed Work
- Registered `/dev/gallery` route in `lib/app/router/app_router.dart` guarded by `if (kDebugMode)`.
- Created `lib/features/dev/component_gallery_screen.dart` and `lib/features/dev/widgets/gallery_interactive_section.dart` showing all components in all states.
- Created `lib/features/home/presentation/widgets/folder_card.dart` and `lib/features/home/presentation/widgets/document_card.dart`.
- Updated `lib/features/home/presentation/home_screen.dart` matching `mocups/home_default/` with `AppTopBar` (menu leading, title, gold crown, search, three-dots, plus gallery in debug mode), Folders row, Documents list, and bottom-right `FabPill` with toast callbacks.
- Created complete test suite across `test/widgets/` for all 13 components plus `test/app_smoke_test.dart` and `test/widget_test.dart` (25 total unit/widget tests).
- Verified `flutter test`: all 25 tests pass.
- Verified `flutter analyze`: zero issues found.
- Verified Android debug APK compiles cleanly.

## Phase 2A Completed Work
- Added packages: `sqflite`, `path_provider`, `path`, `uuid` and dev dependency `sqflite_common_ffi`.
- Implemented core errors and utilities:
  - `lib/core/errors/app_exception.dart` (`AppException`, `NotFoundException`, `ValidationException`)
  - `lib/core/time/clock.dart` (`Clock` typedef, `systemClock`)
  - `lib/core/ids/id_generator.dart` (`IdGenerator` typedef, `newId`)
- Implemented database schema & manager:
  - `lib/core/db/schema.dart` (exact SQL statements for folders, documents, pages, and 4 indexes)
  - `lib/core/db/app_database.dart` (`open`, `close`, `onConfigure` with PRAGMA foreign_keys = ON, `onCreate`, `onUpgrade`)
- Implemented domain models (immutable, const constructors, `fromMap`/`toMap`, `copyWith`, explicit nullable clear methods):
  - `lib/features/folders/domain/folder.dart` (`withDeletedAt`)
  - `lib/features/folders/domain/folder_summary.dart`
  - `lib/features/documents/domain/document.dart` (`withDeletedAt`, `withFolderId`, `withNote`)
  - `lib/features/documents/domain/scan_page.dart` (`withEditedPath`, `displayPath`)
  - `lib/features/documents/domain/document_summary.dart`
  - `lib/features/documents/domain/new_page.dart`
  - `lib/features/documents/domain/document_sort.dart`
- Built database FFI and model unit tests:
  - `test/core/db/app_database_test.dart` (tables & indexes existence, foreign keys pragma, foreign key constraint failure, cascading document deletion)
  - `test/features/folders/domain/folder_test.dart`
  - `test/features/documents/domain/document_test.dart`
  - `test/features/documents/domain/scan_page_test.dart`
  - `test/features/documents/domain/document_summary_test.dart`
- Verified:
  - `flutter analyze`: 0 issues.
  - `flutter test`: all 46 tests pass.
  - File lines: all files strictly <= 150 lines.

## Phase 2B Completed Work
- Implemented `RestoreResult` domain model in `lib/features/trash/domain/restore_result.dart`.
- Implemented `FolderRepository` interface and `SqliteFolderRepository` in `lib/features/folders/`.
- Implemented `DocumentRepository` interface and `SqliteDocumentRepository` in `lib/features/documents/`.
- Extracted `DocumentPageOperations` helper in `lib/features/documents/data/document_page_operations.dart` to maintain strict <= 150 line constraint.
- Implemented `TrashRepository` interface and `SqliteTrashRepository` in `lib/features/trash/`.
- Built integration tests for all 3 repositories:
  - `test/features/folders/data/sqlite_folder_repository_test.dart` (creation, trimming, empty validation, rename, listActive, itemCount, moveToTrash)
  - `test/features/documents/data/sqlite_document_repository_test.dart` (creation, validation, root vs folder lists, all 4 sorts, favorite, moveToFolder, moveToTrash)
  - `test/features/documents/data/sqlite_document_pages_test.dart` (addPages, deletePage, contiguous renumbering, last page rejection, reorderPages)
  - `test/features/trash/data/sqlite_trash_repository_test.dart` (restore to folder vs root, restoreFolder, deleteDocumentForever, deleteFolderForever, emptyTrash, purgeExpired with retention and cascading)
- Verified:
  - `flutter analyze`: zero issues found.
  - `flutter test`: all 67 tests pass (sequential execution verified).
  - All files strictly <= 150 lines.





