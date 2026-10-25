# Findings: flutter_better_scanner & Project Architecture

## Package Details
- Package: `flutter_better_scanner: ^1.0.2`
- Pub cache path: `C:\Users\Prince patel\AppData\Local\Pub\Cache\hosted\pub.dev\flutter_better_scanner-1.0.2\`
- Library entrypoint: `lib/flutter_better_scanner.dart`
- Core CV export: `lib/scanner_core.dart`
- Key classes:
  - `ScannerController`: Headless controller managing camera, detection, capture, pages, crop, filter preview, thumbnails, export.
  - `ScannerPreview`: Composable widget rendering preview texture, outline, framing guide, grid, with gestures.
  - `ScannerConfig`: Configuration (`autoCrop`, `autoEnhance`, `enhancement`, `exportQuality`, `workingResolution`, `autoCaptureTuning`).
  - `ScanPage`: Handle for page with `id`, `recipe` (`quad`, `enhancement`, `rotationQuarterTurns`), `cropCorners`, `aspectRatio`.
  - `Quad`: 4 normalized points (`tl`, `tr`, `br`, `bl`) in 0..1 coordinates.
  - `ScannerCv`: Native C++ methods (`detectDocument`, `warp`, `applyFilter`, `encodeJpeg`).

## Key Package APIs Verified in Source
- `controller.initialize()`: Opens camera stream and CV worker.
- `controller.capture()`: Takes picture, runs CV edge detection if enabled, adds page to `controller.pages`.
- `controller.pages`: `List<ScanPage>`.
- `controller.originalPath(page)`: Untouched high-res camera capture on disk.
- `controller.pagePath(page)`: Rendered / warped / enhanced page on disk.
- `controller.proxyPath(page)`: Preview-sized render (~1400px) on disk.
- `controller.setPageCrop(page, quad)`: Sets crop corners (0..1 normalized `Quad`), re-renders page without black borders.
- `controller.setPageEnhancement(page, enhancement)`: Sets enhancement recipe and re-renders.
- `controller.renderEnhancementThumbnails(page)`: Returns `Future<List<Uint8List>>` (one thumbnail per `ScanEnhancement` in enum order).
- `controller.finish()`: Returns `ScanResult` with paths.

## Mockup References
- `mocups/home_empty`: Illustration, title, subtitle, two hint rows, FabPill. No "Folders (0)" or "Documents (0)" headers.
- `mocups/camera/camera_settings`: Camera HUD, AUTO pill, spirit level, settings grid sheet, flash icon states.
- `mocups/adjust`: Adjust screen with padding, loupe corner magnifier.
- `mocups/review_scan`: Page view on plain background, counter pill below page card, filter strip with thumbnails.
