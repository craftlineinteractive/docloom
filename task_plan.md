# Task Plan: Scanner Engine Migration & 10 Bug Fixes

## Goal
Replace hand-written scanner engine with `flutter_better_scanner` (^1.0.2), keep DocLoom mockup UI, and fix 10 specific scanner/review/home bugs across 4 distinct commits.

## Strict Rules
- Do NOT hand-code camera, edge detection, perspective warp, or filter logic. Use package APIs (`ScannerController`, `ScannerPreview`, `ScannerCv`, `ScannerEditor`, `renderPagePreview`, `renderEnhancementThumbnails`).
- Keep: mockup UI (`mocups/*`), Home, DB, file store, save pipeline, QR (`zxing2`).
- Delete hand-written engine code ONLY after phone verification.
- Tokens only (`lib/core/theme`), files strictly `< 150 lines`.
- No invented APIs (cite package files from pub-cache). Real command output only.

## Phases

### Phase 0: Analysis
- [x] Analyze 5 bug causes (a-e) with exact file:line citations
- [x] Write `docs/analysis.md`
- [x] Git commit `Step 0: analysis of scanner bugs` (`9f0e444`)

### Phase 1: Spike & Benchmark
- [x] Add `flutter_better_scanner: ^1.0.2` to `pubspec.yaml`
- [x] Benchmark IoU across 19 document fixtures on device `KB2005`
- [x] Render 20 filter images (5 fixtures x 4 filters) into `build/filter_report/`
- [x] Measure ms/page and APK size
- [x] Git commit `Step 1: flutter_better_scanner spike and benchmark` (`5daf195`)
- [x] Stop at gate & receive user approval to continue

### Phase 2: Integrate (Commit: `Step 2: integrate flutter_better_scanner into scan flow`)
- [x] Connect `ScannerController` to `CameraScreen` with `ScannerPreview` and DocLoom custom chrome
- [x] Wire camera settings tiles to package config (autoCrop, enhancement, exportQuality/workingResolution, holdDuration, flash, grid)
- [x] Adapt `CropEditor` to read `page.cropCorners` and call `controller.setPageCrop`, clamped 0..1
- [x] Adapt Save Pipeline: `original = originalPath(page)`, `edited = pagePath(page)`, `filterId = enhancement name`, `cropJson = quad`, `rotation = rotation`
- [x] Support modes: Photo, ID Card, Book, Signature, QR via package pages
- [x] Verify `flutter analyze` and tests pass
- [x] Git commit `Step 2: integrate flutter_better_scanner into scan flow`

### Phase 3: Fix 10 Bugs (Commit: `Step 3: fix 10 scanner bugs`)
- [ ] Bug 1: Adjust shows original capture with detected edges. Filters apply only after Continue. Review Crop opens original & saved quad.
- [ ] Bug 2: Corner loupe: ONE circle with ONE 2px ring, "+" center, zoom ~2.5x, dynamic top-left / top-right positioning.
- [ ] Bug 3: Aspect ratio matches selected edges (A4 ~1.41).
- [ ] Bug 4: Camera mode tabs slide to center (`animateTo` ~250ms).
- [ ] Bug 5: Adjust image box has `AppSpacing.xl` padding (left, right, top, bottom).
- [ ] Bug 6: Review filter row shows thumbnails per filter via `renderEnhancementThumbnails`.
- [ ] Bug 7: Retake -> capture -> Continue returns to Camera. Cancel keeps old page.
- [ ] Bug 8: Back dialog: exactly "Save and Exit" and "Discard". Tap outside/back closes and stays.
- [ ] Bug 9: Review shows page on plain background (no black fill, no rounded mask), counter pill below page.
- [ ] Bug 10: Empty Home matches `mocups/home_empty` (no "Folders (0)" or "Documents (0)" headers). Update tests.
- [ ] Verify `flutter analyze` and tests pass
- [ ] Git commit `Step 3: fix 10 scanner bugs`

### Phase 4: Verification & Final Report
- [ ] Run `flutter analyze` and `flutter test` (record before/after counts)
- [ ] One test or measurement per item
- [ ] Output table with FIXED / NOT FIXED / NOT VERIFIED with evidence
