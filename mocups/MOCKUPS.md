# docLoom mockup index
Each folder in mocups/ has an HTML file and a PNG of the same screen.

HOW TO USE
- The PNG shows the look. The HTML gives exact measurements (padding, sizes, radii, icon placement) and structure.
- The HTML is generated web code. NEVER copy Tailwind classes, web fonts or web icon names. Translate measurements into Flutter using the tokens in lib/core/theme.
- Tokens in lib/core/theme are the source of truth. If a mockup disagrees with a token, follow the token.
- Icons: use lucide_icons_flutter. Pick the closest icon that exists in the package.
- Sample text in mockups is placeholder data only.

MUST NOT BE BUILT, even if they appear in a mockup:
OCR banner, "Edge OCR Active" text, PRO pill, profile avatar in the app bar, "Synced" tag, version footer, "Fast" and "OCR Ready" badges, per-folder storage bars, ads, search bar banner.

FOLDERS
home_default        Home with folders and documents, FabPill
home_empty          Home empty state
home_add_sheet      Home "+" bottom sheet
home_menu           Home three-dots dropdown
drawer_signed_out   Drawer, signed out
drawer_general      Drawer, signed in, General expanded
drawer_tools_open   Drawer, Tools and Other expanded
settings            Settings screens
trash               Trash screens
camera, adjust, review_scan, viewer, ocr_result   LATER PHASES. Do not open or build in Phase 1.