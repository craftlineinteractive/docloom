abstract interface class OcrService {
  Future<bool> isLanguageAvailable(String code);
  Future<List<String>> getAvailableLanguageCodes();
  Future<void> downloadLanguage(
    String code, {
    void Function(double progress)? onProgress,
  });
  Future<void> deleteLanguage(String code);
  Future<String> extractText(
    String imagePath, {
    required String languageCode,
  });
}
