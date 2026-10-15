abstract final class AppConfig {
  static const Duration trashRetention = Duration(days: 30);
  static const int scanPageLimit = 50;
  static const int scanMaxSide = 3000;
  static const int previewMaxSide = 1280;
  static const int jpegQuality = 92;
  static const String defaultFilterId = 'vivid_light';
}
