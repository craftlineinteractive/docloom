# Task Plan: Block 4N - Scanner Fix Pack

## Overview
Comprehensive 8-stage scanner fix pack addressing crop geometry, auto edge detection, sharpness & filters, adjust screen, camera mode tabs, back dialog, retake flow & filter thumbnails, and empty home state.

## Stages & Status

- [ ] **Stage 1: Crop Geometry ("result is longer than my edges")**
  - Report first (trace image, paste table: camera photo WxH/EXIF, importCapture, preview file, widget box, letterbox rect, normalized quad, quad in pixels, renderPage output WxH; file renderPage reads; code computing output size).
  - Fix:
    - (a) Preview aspect matches importCapture (error < 0.5%), assert in `makePreview` + test.
    - (b) Output size from edge lengths in PIXELS via `quad.toPixels(imageSize)`, never normalized values.
    - (c) Widget-to-image mapping subtracts letterbox offset, uses displayed rect after rotation, tests for tall, wide, rotated-90.
    - (d) `renderPage` reads full-resolution file.
    - (e) Perspective aspect recovery (Zhang & He) if tilted fixtures have aspect error > 3%.
  - Tests: OpenCV synthetic page aspect 210:297 warped with known quad at 0, 20, 40 deg: aspect within 2%, corners within 1%. CropEditor drag round trip < 1 px.
  - Expected files:
    - `lib/features/scan/domain/image_engine.dart`
    - `lib/features/scan/data/opencv_isolate_ops.dart`
    - `lib/features/scan/data/opencv_transform_ops.dart`
    - `lib/features/scan/presentation/adjust/adjust_screen.dart`
    - `lib/features/scan/presentation/adjust/crop_editor.dart`
    - `lib/features/scan/presentation/adjust/crop_editor_painter.dart`
    - `lib/features/scan/domain/quad.dart`
    - `test/features/scan/data/opencv_crop_geometry_test.dart`

- [ ] **Stage 2: Auto Edge Detection**
  - Baseline evaluation on `test/fixtures/documents/` (file, IoU, corner error, NULL).
  - Debug tooling: `/dev/edge-debug` screen with tabs (gray, blurred, edges, threshold mask, candidates with score/rejection, final quad; export PNGs button).
  - Verification of EXIF orientation, live frame Y plane rotation & row stride, quad ordering.
  - Multi-iteration algorithm refinement (Canny median, Otsu/adaptive, background distance, saturation; convex hull / approxPolyDP / minAreaRect; scoring function; isolate execution).
  - Acceptance: Mean IoU >= 0.90, no fixture < 0.70, runtime < 400 ms.
  - Expected files:
    - `lib/features/scan/data/opencv_edge_detector.dart`
    - `lib/features/scan/presentation/adjust/adjust_screen.dart`
    - `lib/features/dev/presentation/edge_debug_screen.dart`
    - `lib/core/routing/app_router.dart`
    - `test/features/scan/data/opencv_edge_detector_test.dart`

- [x] **Stage 3: Sharpness and Filters**
  - Measurement table on real fixture (photo size, ResolutionPreset, importCapture size, warp output size, re-encodes, jpegQuality, Laplacian variance).
  - Fixes:
    - (a) `ResolutionPreset.max` for stills; scanQuality caps long side (2000, 3000, 4000).
    - (b) Focus settle / wait before capture; skip during motion if accelerometer available.
    - (c) Single pipeline: normalized capture -> warp (INTER_CUBIC / LANCZOS4) -> rotation -> filter -> single JPEG encode at quality 95.
    - (d) Output size from quad in source pixels.
    - (e) Filters: `auto_enhance`, `vivid_light`, `black_white`, `grayscale`, `original`.
    - (f) Previews/thumbnails use same recipes.
  - Tests: Laplacian variance >= 1.3x plain warp, background median >= 235, shadow gap shrink >= 70%, text pixel <= 90, vivid_light chroma +10-40%, black_white 0/255. Contact sheet tool in `build/filter_report/`. Runtime < 2s for 12MP page.
  - Expected files:
    - `lib/features/scan/domain/camera_service.dart`
    - `lib/features/scan/data/flutter_camera_service.dart`
    - `lib/features/scan/domain/scan_quality.dart`
    - `lib/features/scan/data/filter_recipes.dart`
    - `lib/features/scan/data/opencv_transform_ops.dart`
    - `lib/features/scan/data/opencv_isolate_ops.dart`
    - `test/features/scan/data/filter_recipes_test.dart`
    - `test/features/scan/data/filter_contact_sheet_test.dart`

- [ ] **>>> STOP POINT AFTER STAGE 3: Paste results and await "continue" <<<**

- [ ] **Stage 4: Adjust Screen**
  - Show unfiltered original capture; remove live filter preview & row.
  - Review's Crop tool opens original capture with page's saved quad.
  - Image box horizontal padding `AppSpacing.xl`, vertical padding token. 48dp hit areas.
  - Magnifier: 1 circular loupe (120 px, single 2px indigo ring, zoom ~2.5, centered "+" crosshair). Displays opposite to dragged corner side.
  - Expected files:
    - `lib/core/theme/app_spacing.dart`
    - `lib/features/scan/presentation/adjust/adjust_screen.dart`
    - `lib/features/scan/presentation/adjust/crop_editor.dart`
    - `lib/features/scan/presentation/adjust/adjust_magnifier.dart`
    - `lib/features/scan/presentation/review/review_screen.dart`
    - `test/features/scan/presentation/adjust_screen_test.dart`

- [ ] **Stage 5: Camera Mode Tabs**
  - Animate row on tab selection to center selected tab (ScrollController.animateTo ~250ms easeOut). Underline stays with selected tab.
  - Expected files:
    - `lib/features/scan/presentation/camera_mode_row.dart`
    - `test/features/scan/presentation/camera_mode_row_test.dart`

- [ ] **Stage 6: Back Dialog**
  - Dialog "Exit scanning?", body "N pages scanned.", exactly two buttons: "Save and Exit" (filled indigo) and "Discard" (red).
  - Save and Exit renders/saves all pages -> Home. Discard deletes session -> Home. Dismiss on outside tap / gesture. Zero pages leaves without dialog.
  - Expected files:
    - `lib/features/scan/presentation/review/review_dialogs.dart`
    - `lib/features/scan/presentation/camera_screen_helper.dart`
    - `lib/features/scan/presentation/adjust/adjust_screen.dart`
    - `lib/features/scan/presentation/review/review_screen.dart`
    - `test/features/scan/presentation/camera_back_dialog_test.dart`

- [ ] **Stage 7: Retake Flow and Review Filter Thumbnails**
  - Retake from Review opens camera -> capture -> Continue returns to camera with session intact and updated thumbnail. Cancel keeps old page.
  - Review Color tool shows 72px 12px radius filter thumbnails rendered from current crop & rotation with LRU cache.
  - Expected files:
    - `lib/features/scan/presentation/camera_screen.dart`
    - `lib/features/scan/presentation/flows/document_capture_flow.dart`
    - `lib/features/scan/presentation/review/review_screen.dart`
    - `lib/features/scan/presentation/review/review_filter_row.dart`
    - `lib/features/scan/application/scan_session_provider.dart`
    - `test/features/scan/presentation/review_retake_flow_test.dart`

- [ ] **Stage 8: Empty Home**
  - Matches `mocups/home_empty` exactly when no folders & no documents.
  - App bar (search, three-dots), centered illustration, title "Scan your first document", subtitle, hint rows, FabPill. No "Folders (0)" or "Documents (0)".
  - Expected files:
    - `lib/features/home/presentation/home_screen.dart`
    - `lib/features/home/presentation/widgets/home_empty_view.dart`
    - `test/features/home/presentation/home_screen_test.dart`

## Final Deliverable Checklist
- Per-stage git commit: "4N stage X: ..."
- `flutter analyze` and `flutter test` outputs after each stage
- Final report with commit list, test counts, stages 1-3 tables, mockup folders opened/missing, NOT VERIFIED items.
