# Step 0: Root Cause Analysis of Scanner & UI Issues

This document investigates and details the root causes (with exact `file:line` locations) for the 5 scanner and UI issues identified in the DocLoom codebase prior to integrating `flutter_better_scanner`.

---

## Issue (a): Adjust handles sit outside image bounds (quad not clamped to 0..1), causing black border in Review

### Affected Locations
- [`lib/features/scan/presentation/adjust/adjust_crop_container.dart:18-28`](file:///e:/Craftline%20Interactive/docloom/lib/features/scan/presentation/adjust/adjust_crop_container.dart#L18-L28)
- [`lib/features/scan/presentation/adjust/crop_editor.dart:109-141`](file:///e:/Craftline%20Interactive/docloom/lib/features/scan/presentation/adjust/crop_editor.dart#L109-L141)
- [`lib/features/scan/presentation/adjust/crop_painter.dart:45-77`](file:///e:/Craftline%20Interactive/docloom/lib/features/scan/presentation/adjust/crop_painter.dart#L45-L77)
- [`lib/features/scan/domain/quad.dart:77-84`](file:///e:/Craftline%20Interactive/docloom/lib/features/scan/domain/quad.dart#L77-L84)
- [`lib/features/scan/data/opencv_transform_ops.dart:40-45`](file:///e:/Craftline%20Interactive/docloom/lib/features/scan/data/opencv_transform_ops.dart#L40-L45)

### Root Cause & Mechanism
1. **Zero Margin Around Crop Container**: In `AdjustCropContainer` (`adjust_crop_container.dart:18-28`), the child `CropEditor` directly fills the `Expanded` box without `AppSpacing.xl` horizontal and vertical padding.
2. **Handle Geometry Overflow**: In `crop_painter.dart:47`, corner drag handles have a radius of `AppSizes.cropHandleVisible / 2` (12px) plus an 8px touch halo (20px total). When corner points approach `0.0` or `1.0`, the handle circle renders outside the `imageRect` boundary.
3. **Unclamped Quad Mapping**: While `CropCoordinates.widgetToNormalized` has a `clamp: true` parameter, initial quads from `detectFromFile` or rotation transformations (`quad.rotated90()`) and unvalidated initial quad injections can yield points slightly outside `0.0..1.0`. `Quad` itself does not enforce clamping in `toPixels()`.
4. **OpenCV Warp Fill Behavior**: In `OpencvTransformOps.warpAndRotate` (`opencv_transform_ops.dart:42`), `cv.warpPerspective(src, transform, (outW, outH), flags: cv.INTER_CUBIC)` defaults to `BORDER_CONSTANT` with a black value of `0`. Any source point outside `[0, width]` and `[0, height]` is sampled as pure black pixels.
5. **Review Screen Rendering**: When the warped image with black sampled edges is rendered in `ReviewPageCard` (`review_page_card.dart:25-35`) with rounded corners (`AppRadius.md`) and anti-aliased clip, the black border manifests as a black rounded border with dotted corners.

---

## Issue (b): Auto detect returns null or never runs; start quad is full frame

### Affected Locations
- [`lib/features/scan/presentation/adjust/adjust_screen.dart:65`](file:///e:/Craftline%20Interactive/docloom/lib/features/scan/presentation/adjust/adjust_screen.dart#L65)
- [`lib/features/scan/presentation/adjust/adjust_screen.dart:70-76`](file:///e:/Craftline%20Interactive/docloom/lib/features/scan/presentation/adjust/adjust_screen.dart#L70-L76)
- [`lib/features/scan/data/edge_detector_ops.dart:58-94`](file:///e:/Craftline%20Interactive/docloom/lib/features/scan/data/edge_detector_ops.dart#L58-L94)
- [`lib/features/scan/data/edge_detector_evaluator.dart:55-89`](file:///e:/Craftline%20Interactive/docloom/lib/features/scan/data/edge_detector_evaluator.dart#L55-L89)

### Root Cause & Mechanism
1. **Early Return Guard**: In `AdjustScreen._autoDetect` (`adjust_screen.dart:74`), the method executes `if (isInitial && !ref.read(autoCropEnabledProvider)) return;`. If the user toggles auto crop off in settings, detection is completely skipped.
2. **Initial Quad Overwrite**: In `initState` (`adjust_screen.dart:70`), `_autoDetect(isInitial: true)` only fires `if (widget.initialQuad == null && widget.mode.autoDetect)`. If `initialQuad` was passed (such as during re-crop from Review), auto-detection never runs.
3. **Rigid Contour Rejections**: In `EdgeDetectorOps` (`edge_detector_ops.dart:64-94`) and `EdgeDetectorEvaluator` (`edge_detector_evaluator.dart:71-88`), candidate contours are subjected to strict heuristic rejection gates:
   - Area ratio must be between `kMinAreaRatio` (0.15) and `kMaxAreaRatio` (0.95).
   - If all 4 corners are close to borders (`nx <= kBorderMargin`, 8%), it rejects with `"All 4 corners hug border"`.
   - Minimum edge gradient support threshold (`kMinEdgeSupport = 0.55`).
4. **Fallback to Default Inset**: When all candidates are rejected due to low contrast or high-bleed edges, `detectFromFile` returns `null`. Line 79 in `adjust_screen.dart` ignores `null`, leaving `_quad = Quad.defaultInset()` (or unit frame).

---

## Issue (c): Adjust still shows a filtered preview and a filter row

### Affected Locations
- [`lib/features/scan/presentation/adjust/adjust_screen.dart:68-69`](file:///e:/Craftline%20Interactive/docloom/lib/features/scan/presentation/adjust/adjust_screen.dart#L68-L69)
- [`lib/features/scan/presentation/adjust/adjust_screen.dart:87-95`](file:///e:/Craftline%20Interactive/docloom/lib/features/scan/presentation/adjust/adjust_screen.dart#L87-L95)
- [`lib/features/scan/presentation/adjust/adjust_screen.dart:141`](file:///e:/Craftline%20Interactive/docloom/lib/features/scan/presentation/adjust/adjust_screen.dart#L141)
- [`lib/features/scan/presentation/adjust/crop_editor.dart:89-105`](file:///e:/Craftline%20Interactive/docloom/lib/features/scan/presentation/adjust/crop_editor.dart#L89-L105)

### Root Cause & Mechanism
1. **Premature Filter Execution**: In `AdjustScreen.initState` (`adjust_screen.dart:68-69`), the screen initializes `_filterId = widget.initialFilterId ?? AppConfig.defaultFilterId` and immediately invokes `_updatePreviewBytes(_filterId)`.
2. **Filtered Bytes Passed to Editor**: In lines 87-95, `_updatePreviewBytes` calls `engine.renderPreview(...)` which applies the filter recipe (`FilterRecipes.apply`) on `previewBytes`.
3. **UI Display of Filter Controls**: Line 141 renders `AdjustFilterRow(currentFilterId: _filterId, onTapFilter: _openFilterSheet)`, allowing users to modify filter presets in the Adjust screen instead of keeping Adjust strictly focused on edge adjustment of the raw/unfiltered capture.
4. **CropEditor Priority**: In `crop_editor.dart:90-98`, `_buildImage()` checks `if (widget.previewBytes != null)` and renders `Image.memory(bytes)` over the original file `Image.file(File(widget.previewPath))`, thereby displaying the processed filter rather than the raw original document.

---

## Issue (d): The page counter pill overlaps the page in Review

### Affected Locations
- [`lib/features/scan/presentation/review/review_page_view.dart:25-61`](file:///e:/Craftline%20Interactive/docloom/lib/features/scan/presentation/review/review_page_view.dart#L25-L61)
- [`lib/features/scan/presentation/review/review_screen.dart:126-132`](file:///e:/Craftline%20Interactive/docloom/lib/features/scan/presentation/review/review_screen.dart#L126-L132)
- [`lib/features/scan/presentation/review/review_page_card.dart:20-35`](file:///e:/Craftline%20Interactive/docloom/lib/features/scan/presentation/review/review_page_card.dart#L20-L35)

### Root Cause & Mechanism
1. **Stacked Overlay Layout**: In `ReviewPageView` (`review_page_view.dart:25-61`), the view uses a `Stack` containing both `PageView.builder` (which expands to the full height of the widget) and `Positioned(bottom: 16, left: 0, right: 0, child: Center(child: Container(...)))`.
2. **Viewport Overlap**: The page image card in `ReviewPageCard` (`review_page_card.dart:21-35`) uses `margin: EdgeInsets.symmetric(horizontal: 16, vertical: 20)` and expands to the bottom edge of the `PageView`.
3. **Direct Collision**: Because the page counter pill is positioned at `bottom: 16` inside the same stack area, it renders directly on top of the scanned page content rather than having its own dedicated vertical space below the page container.

---

## Issue (e): The output is longer than the selected edges

### Affected Locations
- [`lib/features/scan/domain/perspective_aspect_helper.dart:67-88`](file:///e:/Craftline%20Interactive/docloom/lib/features/scan/domain/perspective_aspect_helper.dart#L67-L88)
- [`lib/features/scan/domain/perspective_aspect_helper.dart:95-104`](file:///e:/Craftline%20Interactive/docloom/lib/features/scan/domain/perspective_aspect_helper.dart#L95-L104)
- [`lib/features/scan/data/opencv_transform_ops.dart:12-24`](file:///e:/Craftline%20Interactive/docloom/lib/features/scan/data/opencv_transform_ops.dart#L12-L24)

### Root Cause & Mechanism
1. **Unstable Perspective Fallback**: In `PerspectiveAspectHelper.recoverOutputDimensions` (`perspective_aspect_helper.dart:67-88`), when the Zhang & He general equation is ill-conditioned, single-axis perspective fallback is computed using an assumed focal length `f = math.max(imageSize.width, imageSize.height) * 1.0` (~3000–4000px).
2. **Sensitivity to Trapezoid Edge Differences**: The focal depth term `dz = f * ((1.0 / wBottom) - (1.0 / wTop))` multiplies tiny edge deviations by several thousand pixels, resulting in an artificially inflated `recH` or `recW`.
3. **Aspect Ratio Enforcement Stretches Dimensions**: In `perspective_aspect_helper.dart:97-104`:
   ```dart
   if (targetWh >= 1.0) {
     finalW = math.max(edgeW, edgeH * targetWh);
     finalH = finalW / targetWh;
   } else {
     finalH = math.max(edgeH, edgeW / targetWh);
     finalW = finalH * targetWh;
   }
   ```
   For portrait documents where `targetWh < 1.0` (e.g., A4 ~0.707), `finalH` is calculated as `math.max(edgeH, edgeW / targetWh)`. If `edgeW` is 1000px, `finalH` is forced to `1000 / 0.707 = 1414px`, even if the user deliberately selected a short or square portion of the document, forcibly stretching the height beyond the selected edge lengths.
