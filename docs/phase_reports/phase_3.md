# Phase 3 Completion & Audit Report: Home, Folders, Documents, and Library Management

**Date:** 2026-10-13  
**Status:** COMPLETE (Phase 3A, 3B, 3C, 3D)  
**Target File:** `docs/phase_reports/phase_3.md`

---

## 1. Baseline Commands

### 1.1 `flutter analyze`
```
Analyzing docloom...                                            
No issues found! (ran in 1.8s)
```

### 1.2 `flutter test`
```
01:29 +137: All tests passed!
```
- **Passed:** 137
- **Failed:** 0
- **Skipped:** 0

### 1.3 `flutter pub outdated` (Summary)
```
Showing outdated packages.
[*] indicates versions that are not the latest available.

Package Name              Current   Upgradable  Resolvable  Latest   

direct dependencies:     
cupertino_icons           *1.0.9    *1.0.9      2.0.0       2.0.0    
lucide_icons_flutter      *3.1.24   3.1.25      3.1.25      3.1.25   

dev_dependencies: all up-to-date.

transitive dependencies: 
clock                     *1.1.2    *1.1.2      *1.1.2      1.1.3    
code_assets               *1.2.1    *1.2.1      *1.2.1      2.1.0    
cupertino_ui              *1.0.2    *1.0.2      *1.0.2      1.1.2    
hooks                     *2.0.2    *2.0.2      *2.0.2      2.2.0    
intl                      *0.20.2   *0.20.2     *0.20.2     0.20.3   
matcher                   *0.12.19  *0.12.19    *0.12.19    0.12.20  
material_color_utilities  *0.13.0   *0.13.0     *0.13.0     0.13.1   
material_ui               *1.2.0    *1.2.0      *1.2.0      1.6.0    
meta                      *1.18.0   *1.18.0     *1.18.0     1.19.0   
objective_c               *9.5.0    *9.5.0      *9.5.0      9.6.2    
record_use                *0.6.0    *0.6.0      *0.6.0      1.1.1    
stack_trace               *1.12.1   *1.12.1     *1.12.1     1.12.2   
test_api                  *0.7.11   *0.7.11     *0.7.11     0.7.15   
vector_math               *2.2.0    *2.2.0      *2.2.0      2.4.3    

transitive dev_dependencies:
native_toolchain_c        *0.19.2   *0.19.2     *0.19.2     0.19.5   
sqlite3                   *3.5.2    *3.5.2      *3.5.2      3.7.0    
```

### 1.4 `git status --short` and `git log --oneline -15`
```
(clean - no modified or untracked files)
```
```
b4fe2b4 Phase 3D: implement document and trash management features with UI and database repositories
e848445 Phase 3C: implement home and folders features with CRUD operations and UI components
a2b4e7d Phase 3B: implement home screen UI components, theme colors, and tests
c02663c Phase 3A: add storage lifecycle, seed data, and document management features with tests
e3cdad5 feat: add SQLite repository implementations, trash feature queries, and database diagnostic screen with tests
faa65cf feat: add home screen, folder card widget, document SQL queries, and database check tests
25f0750 phase 1 a, b, c and 2 a, b and c completed
```

---

## 2. File Inventory

### 2.1 Top 10 Longest Files
| Lines | File | Status (<= 150) |
|---|---|---|
| 147 | `lib/features/trash/data/sqlite_trash_repository.dart` | PASS |
| 146 | `lib/features/home/presentation/widgets/folder_actions_sheet.dart` | PASS |
| 146 | `lib/features/documents/data/sqlite_document_repository.dart` | PASS |
| 143 | `test/integration/storage_lifecycle_test.dart` | PASS |
| 143 | `lib/core/widgets/settings_row.dart` | PASS |
| 143 | `lib/features/home/presentation/widgets/document_card.dart` | PASS |
| 139 | `lib/core/storage/document_file_store.dart` | PASS |
| 139 | `lib/core/widgets/app_button.dart` | PASS |
| 138 | `lib/features/documents/domain/document.dart` | PASS |
| 137 | `lib/features/home/presentation/widgets/document_actions_sheet.dart` | PASS |

**Flagged files > 150 lines:** `NONE (all files <= 150 lines)`.

### 2.2 Complete Tree and Line Counts
```
lib/
  app/
    app.dart (17)
    bootstrap.dart (25)
    router/
      app_router.dart (38)
      routes.dart (8)
  core/
    constants/app_config.dart (3)
    db/
      app_database.dart (39)
      schema.dart (39)
    errors/app_exception.dart (16)
    ids/id_generator.dart (5)
    providers/
      app_providers.dart (70)
      home_providers.dart (124)
    storage/document_file_store.dart (139)
    theme/
      app_colors.dart (32)
      app_radius.dart (3)
      app_shadows.dart (7)
      app_sizes.dart (3)
      app_spacing.dart (5)
      app_theme.dart (55)
      app_typography.dart (51)
    time/
      clock.dart (3)
      relative_time.dart (46)
    widgets/
      app_bottom_sheet.dart (92)
      app_button.dart (139)
      app_card.dart (52)
      app_dialog.dart (95)
      app_icon_button.dart (56)
      app_text_field.dart (98)
      app_toast.dart (66)
      app_top_bar.dart (54)
      empty_state.dart (70)
      fab_pill.dart (90)
      page_thumbnail.dart (80)
      section_header.dart (39)
      settings_row.dart (143)
      tinted_icon.dart (42)
      widgets.dart (14)
  features/
    dev/
      component_gallery_screen.dart (126)
      db_check_actions.dart (73)
      db_check_screen.dart (96)
      seed_data.dart (97)
      seed_image_generator.dart (33)
      widgets/
        db_check_action_buttons.dart (83)
        db_check_stats_card.dart (85)
        gallery_interactive_section.dart (111)
    documents/
      data/
        document_page_operations.dart (117)
        document_repo_helpers.dart (40)
        document_sql.dart (57)
        sqlite_document_repository.dart (146)
      domain/
        document.dart (138)
        document_repository.dart (34)
        document_sort.dart (6)
        document_summary.dart (51)
        new_page.dart (33)
        scan_page.dart (112)
    folders/
      data/sqlite_folder_repository.dart (133)
      domain/
        folder.dart (100)
        folder_repository.dart (11)
        folder_summary.dart (34)
      presentation/
        folder_screen.dart (115)
    home/
      application/library_actions.dart (117)
      presentation/
        home_screen.dart (99)
        widgets/
          document_actions_sheet.dart (137)
          document_card.dart (143)
          document_grid_tile.dart (120)
          document_list_sliver.dart (117)
          document_move_sheet.dart (136)
          document_rename_dialog.dart (131)
          folder_actions_sheet.dart (146)
          folder_card.dart (90)
          folder_color_dialog.dart (86)
          folder_edit_dialog.dart (131)
          folder_palette_row.dart (44)
          folders_section_sliver.dart (69)
          home_add_sheet.dart (121)
          home_overflow_menu.dart (120)
          round_checkbox.dart (32)
          select_action_bar.dart (65)
          sort_dialog.dart (117)
    search/
      presentation/search_screen.dart (126)
    trash/
      application/trash_service.dart (79)
      data/
        sqlite_trash_repository.dart (147)
        trash_sql.dart (18)
      domain/
        restore_result.dart (18)
        trash_repository.dart (15)
  main.dart (24)

test/
  app_smoke_test.dart (45)
  core/
    db/app_database_test.dart (115)
    providers/
      app_providers_test.dart (63)
      home_providers_test.dart (81)
    storage/document_file_store_test.dart (130)
    time/relative_time_test.dart (69)
    widgets/page_thumbnail_test.dart (48)
  features/
    dev/
      db_check_empty_test.dart (77)
      db_check_screen_test.dart (120)
      seed_data_test.dart (85)
    documents/
      data/
        sqlite_document_pages_test.dart (105)
        sqlite_document_repository_test.dart (117)
        sqlite_document_search_test.dart (62)
      domain/
        document_summary_test.dart (59)
        document_test.dart (121)
        scan_page_test.dart (87)
    folders/
      data/sqlite_folder_repository_test.dart (96)
      domain/folder_test.dart (98)
      presentation/folder_screen_widget_test.dart (101)
    home/
      application/
        library_actions_docs_test.dart (84)
        library_actions_test.dart (74)
      presentation/
        document_crud_widget_test.dart (134)
        folder_crud_widget_test.dart (132)
        home_menu_and_sort_widget_test.dart (127)
        home_screen_actions_test.dart (122)
        home_screen_test.dart (123)
        select_mode_widget_test.dart (128)
    regression/repository_bugs_test.dart (125)
    search/presentation/search_screen_widget_test.dart (88)
    trash/data/sqlite_trash_repository_test.dart (121)
  integration/
    storage_lifecycle_test.dart (143)
    storage_orphan_cleanup_test.dart (77)
  widgets/
    app_bottom_sheet_test.dart (39)
    app_button_test.dart (63)
    app_card_test.dart (41)
    app_dialog_test.dart (51)
    app_icon_button_test.dart (52)
    app_text_field_test.dart (49)
    app_toast_test.dart (41)
    app_top_bar_test.dart (38)
    empty_state_test.dart (34)
    fab_pill_test.dart (35)
    section_header_test.dart (39)
    settings_row_test.dart (96)
    tinted_icon_test.dart (43)
```

### 2.3 Files Created vs Changed in Phase 3D
- **Created in Phase 3D:**
  - `lib/features/documents/data/document_repo_helpers.dart`: Helper functions for input assertions and SQL LIKE escaping to keep `sqlite_document_repository.dart` <= 150 lines.
  - `lib/features/home/presentation/widgets/document_grid_tile.dart`: 2-column grid item for `ViewMode.grid`.
  - `lib/features/home/presentation/widgets/folders_section_sliver.dart`: Extracted folders section sliver for clean separation and line compliance.
  - `lib/features/home/presentation/widgets/home_overflow_menu.dart`: 4-item overflow dropdown on Home and 3-item on FolderScreen.
  - `lib/features/home/presentation/widgets/round_checkbox.dart`: Shared round checkbox indicator for select mode.
  - `lib/features/home/presentation/widgets/select_action_bar.dart`: Bottom action bar for batch Move and Delete.
  - `lib/features/home/presentation/widgets/sort_dialog.dart`: Radio dialog for `DocumentSort`.
  - `lib/features/search/presentation/search_screen.dart`: Debounced active document search screen.
  - `test/features/documents/data/sqlite_document_search_test.dart`: Database search unit tests.
  - `test/features/home/presentation/home_menu_and_sort_widget_test.dart`: Menu, sort, and view mode tests.
  - `test/features/home/presentation/select_mode_widget_test.dart`: Select mode and batch delete tests.
  - `test/features/search/presentation/search_screen_widget_test.dart`: Search screen UI and debounce tests.
  - `tool/check_lines.dart`: Automated verification script asserting all files <= 150 lines.
- **Changed from Earlier Phases in Phase 3D:**
  - `lib/app/router/routes.dart` & `lib/app/router/app_router.dart`: Added `/search` route.
  - `lib/core/providers/home_providers.dart`: Added `documentSortProvider`, `viewModeProvider`, `selectionProvider`, `selectModeProvider`, and folder sorting.
  - `lib/core/widgets/app_card.dart`: Added optional `border` parameter for selection styling.
  - `lib/core/widgets/app_text_field.dart`: Added `autofocus`, `prefixIcon`, and `suffixIcon` parameters.
  - `lib/features/documents/data/document_sql.dart`: Added `searchActiveByName` query with folder join.
  - `lib/features/documents/data/sqlite_document_repository.dart`: Implemented `searchByName(query)`.
  - `lib/features/documents/domain/document_repository.dart`: Added `searchByName` interface method.
  - `lib/features/documents/domain/document_summary.dart`: Added optional `folderName` field.
  - `lib/features/folders/presentation/folder_screen.dart`: Integrated overflow menu, selection mode, and batch action bar.
  - `lib/features/home/application/library_actions.dart`: Added `deleteDocuments`, `undoDeleteDocuments`, `moveDocuments`, and `batchDeleteWithToast`.
  - `lib/features/home/presentation/home_screen.dart`: Integrated search button, overflow menu, selection mode, and permanent sections.
  - `lib/features/home/presentation/widgets/document_card.dart`: Added select mode toggle, round checkbox, and folder name label.
  - `lib/features/home/presentation/widgets/document_list_sliver.dart`: Added Grid vs List rendering and selection integration.
  - `lib/features/home/presentation/widgets/document_move_sheet.dart`: Added batch move support.
  - `lib/features/trash/data/sqlite_trash_repository.dart`: Implemented atomic `restoreDocuments(ids)`.
  - `lib/features/trash/domain/trash_repository.dart`: Added `restoreDocuments` interface method.

---

## 3. Rule Scans

### 3.1 Hex colors or `Color(` outside `lib/core/theme`:
- Matches in `lib/features/dev/seed_image_generator.dart:11,24`: `ui.Color(0xFFFFFFFF)` used strictly by synthetic canvas drawer for generating test document images.
- Matches in `lib/core/theme/*`: All app colors defined as tokens.
- **Outside theme & dev tool:** NONE.

### 3.2 Numeric Literals for Sizes / Padding / Radius:
- All layout paddings use `AppSpacing.*` tokens.
- All border radii use `AppRadius.*` tokens.
- Small non-token micro-paddings identified:
  - `lib/features/home/presentation/widgets/document_grid_tile.dart:109`: `EdgeInsets.all(2)` for inner options button.
  - `lib/features/home/presentation/widgets/home_overflow_menu.dart:63,111`: `fontSize: 11` and `fontSize: 12` for micro menu pill captions.

### 3.3 `DateTime.now()` outside `lib/core/time/clock.dart`:
- `lib/features/dev/db_check_screen.dart:30`: UI logger timestamp for dev screen.
- `lib/features/dev/db_check_actions.dart:26`: Random name suffix for dev seed document.
- **Production code:** NONE. All domain and repository timestamps use injected `clock()` from `clockProvider`.

### 3.4 Raw `deleted_at` outside `document_sql.dart` and trash/folder repositories:
- **Result:** NONE. Encapsulated entirely in SQLite repositories, data SQL definitions, and domain `toMap`/`fromMap`.

### 3.5 SQL String Interpolation:
- **Result:** NONE for user inputs. Parameterized SQL queries with `?` and `whereArgs` exclusively. Only static compile-time fragments (`$activeWhere`, `$joinFolder`, `orderClause(sort)`) are assembled.

### 3.6 `print(` calls:
- **Result:** NONE in `lib/`. (One in CLI verification tool `tool/check_lines.dart` with ignore directive).

### 3.7 Strings: TODO, FIXME, HACK, "coming soon", "later phase":
- `TODO`: NONE.
- `FIXME`: NONE.
- `HACK`: NONE.
- `coming soon`: NONE.
- `later phase`:
  - `lib/features/search/presentation/search_screen.dart:92`: `'Viewer comes in a later phase'`
  - `lib/features/home/presentation/widgets/home_add_sheet.dart:29`: `'Import comes in a later phase'`
  - `lib/features/home/presentation/widgets/document_list_sliver.dart:65,77`: `'Viewer comes in a later phase'`
- `Phase 4`:
  - `lib/features/home/presentation/home_screen.dart:87`: `'Scanning arrives in Phase 4'`
  - `lib/features/folders/presentation/folder_screen.dart:104`: `'Scanning arrives in Phase 4'`

### 3.8 Empty Callbacks:
- `folder_card.dart:38`: `onTap: onTap ?? () {}` (default null-safety handler).
- `document_card.dart:137`: `onPressed: onOptionsPressed ?? () {}` (default null-safety handler).
- `component_gallery_screen.dart:36-40,53,83,102`: Dev gallery display instances for static button widgets.

### 3.9 Packages in `pubspec.yaml`:
- All packages correspond directly to core app requirements (`flutter_riverpod`, `go_router`, `lucide_icons_flutter`, `sqflite`, `path_provider`, `path`, `uuid`).
- Zero unapproved packages (no `shared_preferences`, etc.).

### 3.10 `// ignore:` Comments:
- `tool/check_lines.dart:1`: `// ignore_for_file: avoid_print` (command-line verification tool).
- In `lib/`: NONE.
- In `test/`: NONE.

---

## 4. Duplication and Dead Code

- **Shared Document List:** `DocumentListSliver` handles both Home (`folderId == null`) and Folder (`folderId != null`) screens with zero duplicated rendering logic.
- **Shared Checkbox:** `RoundCheckbox` handles selection indicators across both list cards and grid tiles.
- **Unused Widgets in `lib/core/widgets`:** `SettingsRow` is currently only utilized in `ComponentGalleryScreen`; pre-built for Phase 5 settings modules.
- **Dead Classes / Functions:** None.

---

## 5. Test Quality

- **Total Test Files:** 45 files.
- **Total Tests:** 137 tests.
- **Skipped Tests:** 0.
- **Tests without `expect()`:** 0.
- **Tests checking only render without assertions:** 0.
- **Real Network:** 0 tests make network calls.
- **Real File System Outside Temp Directory:** 0 tests touch real storage; all use `Directory.systemTemp.createTemp` with teardown cleanup.
- **Real Clock:** 0 tests depend on real system clock elapsed time.

### Feature Coverage Breakdown (Phase 3D):
- **Overflow Menu (Home 4 items, Folder 3 items):** Covered by `home_menu_and_sort_widget_test.dart`.
- **Sort By Dialog & Document/Folder Sorting:** Covered by `home_menu_and_sort_widget_test.dart` and `home_providers_test.dart`.
- **View Mode (List & Grid):** Covered by `home_menu_and_sort_widget_test.dart`.
- **Select Mode (Multi-select, Select All, Cancel):** Covered by `select_mode_widget_test.dart`.
- **Batch Delete & Atomic Undo:** Covered by `select_mode_widget_test.dart` and `sqlite_trash_repository_test.dart`.
- **Batch Move:** Covered by `library_actions_docs_test.dart`.
- **Search (Parameterized SQL, Wildcard Escaping, Folder Name, Empty States):** Covered by `sqlite_document_search_test.dart` and `search_screen_widget_test.dart`.

---

## 6. Phase-Specific Checks

| Check | Result | Evidence |
|---|---|---|
| Home and FolderScreen share one document list widget | **YES** | `lib/features/home/presentation/widgets/document_list_sliver.dart` used in both |
| No shrinkWrap list inside a Column on main screens | **YES** | CustomScrollView slivers used exclusively; 0 matches for `shrinkWrap` in `lib/` |
| Every mutation goes through refreshLibrary | **YES** | All 14 mutation call sites verified in `library_actions.dart`, sheets, and dialogs |
| Relative dates use clockProvider, not DateTime.now() | **YES** | `relativeTime(doc.document.updatedAt, clock())` used everywhere |
| Every Undo path is tested (document, folder, batch) | **YES** | `document_crud_widget_test.dart`, `folder_crud_widget_test.dart`, `select_mode_widget_test.dart` |
| Search escapes % and _ and excludes trashed items | **YES** | `DocumentRepoHelpers.escapeSqlLike`, tested in `sqlite_document_search_test.dart` |
| Menu has exactly: Sort By, Select, Create Folder, View Mode | **YES** | `HomeOverflowMenu` lines 45-110 |
| Thumbnails use cacheWidth, missing file shows placeholder | **YES** | `PageThumbnail` uses `cacheWidth: 200`, errorBuilder; tested in `page_thumbnail_test.dart` |
| Select mode clears on leaving screen or changing folder | **YES** | Handled by `PopScope` and notifier exit calls |
| Performance: real phone scroll with seeded data | **NOT VERIFIED** | Not instrumented with frame timing profiling tool in this session |
| No crown, hamburger, avatar, PRO pill or banner exists | **YES** | Verified in `home_screen.dart` AppBar |

---

## 7. Architecture Snapshot

### 7.1 Provider Inventory
- `appDatabaseProvider`: `Provider<AppDatabase>` (Root SQLite instance)
- `fileStoreProvider`: `Provider<DocumentFileStore>` (Filesystem sandbox store)
- `clockProvider`: `Provider<Clock>` (Injected testable clock)
- `uuidProvider`: `Provider<UuidGenerator>` (Unique ID generator)
- `folderRepositoryProvider`: `Provider<FolderRepository>` -> depends on `appDatabaseProvider`
- `documentRepositoryProvider`: `Provider<DocumentRepository>` -> depends on `appDatabaseProvider`, `clockProvider`, `fileStoreProvider`
- `trashRepositoryProvider`: `Provider<TrashRepository>` -> depends on `appDatabaseProvider`, `clockProvider`, `fileStoreProvider`
- `documentSortProvider`: `NotifierProvider<DocumentSortNotifier, DocumentSort>` (In-memory sort state)
- `viewModeProvider`: `NotifierProvider<ViewModeNotifier, ViewMode>` (In-memory list/grid state)
- `selectionProvider`: `NotifierProvider<SelectionNotifier, Set<String>>` (Active selection set)
- `selectModeProvider`: `NotifierProvider<SelectModeNotifier, bool>` (Select mode active flag)
- `foldersProvider`: `FutureProvider<List<FolderSummary>>` -> depends on `folderRepositoryProvider`, `documentSortProvider`
- `documentsProvider`: `FutureProvider.family<List<DocumentSummary>, String?>` -> depends on `documentRepositoryProvider`, `documentSortProvider`
- `folderByIdProvider`: `FutureProvider.family<Folder?, String>` -> depends on `folderRepositoryProvider`
- `libraryActionsProvider`: `Provider<LibraryActions>` -> depends on `folderRepositoryProvider`, `documentRepositoryProvider`, `trashRepositoryProvider`

### 7.2 Data Flow of Primary Action (Batch Delete with Undo)
1. **User Action:** User enters select mode, selects items, and taps "Delete" on `SelectActionBar`.
2. **Action Layer:** Calls `batchDeleteWithToast(context, ref, selectedIds)`.
3. **Selection Reset:** `selectModeProvider` exits and `selectionProvider` clears immediately.
4. **Data Repository:** Iterates IDs and updates `deleted_at = now` on `documents` table via `sqlite_document_repository.dart`.
5. **State Invalidation:** Calls `ref.refreshLibrary()`, invalidating `documentsProvider` and `foldersProvider`.
6. **UI Refresh:** `HomeScreen` automatically re-fetches active items and updates list without the deleted items.
7. **Snackbar & Undo:** A floating toast displays `"N documents moved to Trash"` with an `"Undo"` action for 5 seconds.
8. **Undo Trigger:** Tapping "Undo" invokes `undoDeleteDocuments(ids)`, executing an atomic SQLite transaction via `sqlite_trash_repository.dart` that clears `deleted_at`.
9. **Final Refresh:** Calls `ref.refreshLibrary()`, immediately restoring documents in the UI.

---

## 8. Deviations
- **Permanent Folders and Documents Sections:** Removed the mockup's full-screen empty illustration state (`Scan your first document`) in favor of permanently visible `Folders (0)` (retaining the folder creation button under the top bar) and `Documents (0)` headers per explicit user instructions.
- **Folder Sorting:** Extended `foldersProvider` to sort folders by the active `documentSortProvider` criteria so folder items also re-order when changing sort.
- **Custom Radio Buttons:** Implemented custom styled indicator circles in `SortDialog` to prevent deprecation warnings in newer Flutter versions while preserving design tokens.

---

## 9. Known Issues
- **Document Viewer Placeholder (Minor):** Tapping document cards displays a toast (`Viewer comes in a later phase`) as designed until Phase 5.
- **Camera Scanning Placeholder (Minor):** Tapping the camera button displays a toast (`Scanning arrives in Phase 4`) until Phase 4.
- **File Import Placeholder (Minor):** Tapping import files displays a toast (`Import comes in a later phase`).

---

## 10. Not Verified
- Real device 60fps/120fps frame timing analysis during high-speed fling scrolling.
- Low storage / out-of-disk exception handling during bulk write operations.
- Process death recovery during active background SQLite transactions.

---

## 11. Risks for the Next Phase (Phase 4: Camera & Document Ingestion)
- **Image Memory Overhead:** Full-resolution camera captures must be efficiently downscaled and compressed to avoid Out-Of-Memory exceptions on low-tier Android devices.
- **File System Consistency:** Page image files and SQLite database entries must remain strictly synchronized to avoid orphaned image files.
- **Storage Cleanup:** Image deletions must cascade properly to physical files using `DocumentFileStore`.

---

## 12. Verdict

### **VERDICT: READY**

#### Top 5 Problems Ranked by Severity:
1. **[Minor] Missing Camera & OCR Ingestion:** Camera scanning currently displays placeholder toast pending Phase 4 implementation.
2. **[Minor] Missing Document Viewer:** Document cards display placeholder toast pending Phase 5 implementation.
3. **[Minor] Missing File Import:** Import flow currently displays placeholder toast pending implementation.
4. **[Minor] Non-Persistent UI Preferences:** Sort and View mode are stored in-memory per specification; preferences reset upon app process restart.
5. **[Minor] In-Memory Search Index:** Search uses direct parameterized SQL query rather than FTS5 full-text index (acceptable for current document count < 1000).
