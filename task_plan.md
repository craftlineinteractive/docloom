# Task Plan: Replace Scanner Engine with flutter_better_scanner

## Overview
Replace hand-written scanner engine with `flutter_better_scanner` (^1.0.2), keeping DocLoom mockup UI, and fix 10 specific bugs across 4 steps (one commit each), with a mandatory stop point at Step 1.

## Rules & Constraints
- Use package for all camera, edge detection, perspective warp, and filter logic (`ScannerController`, `ScannerPreview`, `ScannerCv`, `ScannerEditor`, `renderPagePreview`, `renderEnhancementThumbnails`).
- Keep UI screens (`mocups/*`), Home, DB, file store, save pipeline, QR (`zxing2`).
- Delete hand-written engine code ONLY after replacement works on user's phone.
- Tokens only (`lib/core/theme`), files strictly < 150 lines.
- No invented APIs (verify source in pub-cache).
- Real command output only, `NOT VERIFIED` for anything unrun.

## Steps & Status

- [ ] **Step 0: ANALYSE (no code changes)**
  - Investigate the codebase and write `docs/analysis.md` citing `file:line` for:
    - a) Adjust handles sit outside image bounds (quad not clamped to 0..1), causing black border.
    - b) Auto detect returns null or never runs; start quad is full frame.
    - c) Adjust still shows filtered preview and filter row.
    - d) Page counter pill overlaps page in Review.
    - e) Output is longer than selected edges.
  - Commit: `Step 0: analysis of scanner bugs`

- [ ] **Step 1: SPIKE (throwaway screen /dev/scanner-spike)**
  - Add `flutter_better_scanner` (^1.0.2, minSdk 24, NDK/CMake, iOS 13).
  - On `test/fixtures/documents`: run `ScannerCv.detectDocument` and print table of IoU against ground-truth JSON (NULL = 0) with mean and worst.
  - Render 5 fixtures with `auto`, `magicColor`, `blackWhite`, `shadowRemoval` into `build/filter_report/` (contact sheet).
  - Report ms per page and APK size on phone.
  - Commit: `Step 1: flutter_better_scanner spike and benchmark`
  - **>>> MANDATORY GATE: STOP and wait for user to type "continue" <<<**

- [ ] **Step 2: INTEGRATE (after "continue")**
  - `ScannerController` (headless) owns camera, preview, detection, capture, pages, crop, enhancement, rendering.
  - Camera screen = `ScannerPreview` + mockup chrome.
  - Settings tiles map to package config; Spirit Level stays ours.
  - `CropEditor` stays UI only, reads `page.cropCorners`, writes `controller.setPageCrop`, clamped 0..1.
  - Save pipeline: original = `originalPath`, edited = `pagePath`, filterId = enhancement name, cropJson = quad, rotation = rotation.
  - Modes (Photo, ID Card, Book, Signature, QR) take pages from package.
  - Commit: `Step 2: integrate flutter_better_scanner engine`

- [ ] **Step 3: FIX 10 BUGS**
  - 1. Adjust shows ORIGINAL capture; filters apply only after Continue; Review's Crop opens original + saved quad.
  - 2. Loupe: 1 circle, 1 2px ring, centered "+", zoom ~2.5, opposite top corner.
  - 3. Aspect check on A4 photo shot at angle: ~1.41.
  - 4. Selected camera mode tab slides to center (animateTo ~250ms).
  - 5. Adjust image box has `AppSpacing.xl` padding left/right/top/bottom.
  - 6. Review filter row shows thumbnails via `renderEnhancementThumbnails`.
  - 7. Retake -> capture -> Continue returns to CAMERA screen.
  - 8. Back with scanned pages dialog: "Save and Exit" & "Discard".
  - 9. Review shows ONLY page on plain background (no black fill/rounded mask), counter pill below page.
  - 10. Empty Home matches `mocups/home_empty` (no "Folders (0)" / "Documents (0)").
  - Commit: `Step 3: fix 10 scanner and ui bugs`

- [ ] **Step 4: VERIFY**
  - `flutter analyze` and `flutter test` (counts before/after).
  - One test or measurement per item.
  - Final report: FIXED / NOT FIXED / NOT VERIFIED with evidence.
