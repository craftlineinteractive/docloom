# Findings & Context: docLoom Phase 1A

## Project Overview
- App: docLoom (Android document scanner app in Flutter)
- Target: Phase 1A = Setup + Theme + App Shell Only
- SDK: Dart ^3.12.2 / Flutter latest

## Discoveries & Existing Assets
- `assets/fonts/Inter-Regular.ttf`, `Inter-Medium.ttf`, `Inter-SemiBold.ttf` are already present in `assets/fonts/`.
- Pubspec already has `cupertino_icons` and standard dev_dependencies.
- Connected test device: Android `KB2005` (Android 14 API 34), Windows desktop, Chrome, Edge.

## Rules & Constraints
1. No hex colors, magic numbers, or inline TextStyles outside `lib/core/theme`.
2. No file over 150 lines.
3. Strict API correctness: no invented APIs.
4. No work on subsequent phases (no camera, no database, no complex screens).
5. Must run `flutter analyze` and report real output.
