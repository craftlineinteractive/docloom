# Findings & Discovery Log: Block 4N Scanner Fix Pack

## Mockups Checked
- `mocups/MOCKUPS.md`: Read and verified.
- `mocups/adjust/*`: `adjust_crop_detail`, `adjust_default`, `adjust_filter_sheet` present.
- `mocups/camera/camera_settings`: Present (`code.html`, `screen.png`).
- `mocups/review_scan`: Present (`code.html`, `screen.png`).
- `mocups/home_empty`: Present (`code.html`, `screen.png`).
- Missing folders: None.

## Architecture & Codebase Baseline
- Riverpod 3 (no code generation).
- All files must remain < 150 lines.
- Tokens in `lib/core/theme/` are source of truth.
- OpenCV via `dartcv4` (`opencv_dart`).

## Stage-specific Findings
*(To be populated as each stage investigates)*
