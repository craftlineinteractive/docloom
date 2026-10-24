import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/tesseract_ocr_service.dart';
import '../domain/ocr_language.dart';
import '../domain/ocr_service.dart';

final ocrServiceProvider = Provider<OcrService>((ref) {
  return TesseractOcrService();
});

class ActiveOcrLanguageNotifier extends Notifier<OcrLanguage> {
  @override
  OcrLanguage build() => OcrLanguage.defaultLanguage;

  void selectLanguage(OcrLanguage lang) {
    state = lang;
  }
}

final activeOcrLanguageProvider =
    NotifierProvider<ActiveOcrLanguageNotifier, OcrLanguage>(
  ActiveOcrLanguageNotifier.new,
);

class DownloadedLanguagesNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    final service = ref.read(ocrServiceProvider);
    return service.getAvailableLanguageCodes();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(ocrServiceProvider);
      return service.getAvailableLanguageCodes();
    });
  }

  Future<void> download(OcrLanguage lang) async {
    final service = ref.read(ocrServiceProvider);
    final progressNotifier =
        ref.read(languageDownloadProgressProvider.notifier);
    try {
      progressNotifier.setProgress(lang.code, 0.01);
      await service.downloadLanguage(
        lang.code,
        onProgress: (p) => progressNotifier.setProgress(lang.code, p),
      );
      await refresh();
      ref.read(activeOcrLanguageProvider.notifier).selectLanguage(lang);
    } finally {
      progressNotifier.clearProgress(lang.code);
    }
  }

  Future<void> delete(String code) async {
    final service = ref.read(ocrServiceProvider);
    await service.deleteLanguage(code);
    await refresh();
    if (ref.read(activeOcrLanguageProvider).code == code) {
      ref.read(activeOcrLanguageProvider.notifier).selectLanguage(
            OcrLanguage.defaultLanguage,
          );
    }
  }
}

final downloadedLanguagesProvider =
    AsyncNotifierProvider<DownloadedLanguagesNotifier, List<String>>(
  DownloadedLanguagesNotifier.new,
);

class LanguageDownloadProgressNotifier extends Notifier<Map<String, double>> {
  @override
  Map<String, double> build() => {};

  void setProgress(String code, double progress) {
    state = {...state, code: progress};
  }

  void clearProgress(String code) {
    final copy = Map<String, double>.from(state)..remove(code);
    state = copy;
  }
}

final languageDownloadProgressProvider =
    NotifierProvider<LanguageDownloadProgressNotifier, Map<String, double>>(
  LanguageDownloadProgressNotifier.new,
);
