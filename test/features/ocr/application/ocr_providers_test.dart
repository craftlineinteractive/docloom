import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/features/ocr/application/ocr_providers.dart';
import 'package:docloom/features/ocr/domain/ocr_language.dart';
import 'package:docloom/features/ocr/domain/ocr_service.dart';

class _FakeOcrService implements OcrService {
  final List<String> available = ['eng'];

  @override
  Future<bool> isLanguageAvailable(String code) async => available.contains(code);

  @override
  Future<List<String>> getAvailableLanguageCodes() async => List.unmodifiable(available);

  @override
  Future<void> downloadLanguage(String code, {void Function(double)? onProgress}) async {
    onProgress?.call(0.5);
    onProgress?.call(1.0);
    if (!available.contains(code)) available.add(code);
  }

  @override
  Future<void> deleteLanguage(String code) async {
    available.remove(code);
  }

  @override
  Future<String> extractText(String imagePath, {required String languageCode}) async =>
      'Extracted text in $languageCode';
}

void main() {
  group('activeOcrLanguageProvider', () {
    test('defaults to English and allows selection', () {
      final ref = ProviderContainer();
      addTearDown(ref.dispose);

      expect(ref.read(activeOcrLanguageProvider).code, equals('eng'));

      final hindi = OcrLanguage.fromCode('hin');
      ref.read(activeOcrLanguageProvider.notifier).selectLanguage(hindi);
      expect(ref.read(activeOcrLanguageProvider).code, equals('hin'));
    });
  });

  group('languageDownloadProgressProvider', () {
    test('tracks and clears progress per language code', () {
      final ref = ProviderContainer();
      addTearDown(ref.dispose);

      final notifier = ref.read(languageDownloadProgressProvider.notifier);
      expect(ref.read(languageDownloadProgressProvider), isEmpty);

      notifier.setProgress('guj', 0.45);
      expect(ref.read(languageDownloadProgressProvider)['guj'], equals(0.45));

      notifier.clearProgress('guj');
      expect(ref.read(languageDownloadProgressProvider).containsKey('guj'), isFalse);
    });
  });

  group('downloadedLanguagesProvider', () {
    test('loads available languages, downloads new one, and deletes', () async {
      final fakeService = _FakeOcrService();
      final ref = ProviderContainer(
        overrides: [
          ocrServiceProvider.overrideWithValue(fakeService),
        ],
      );
      addTearDown(ref.dispose);

      final initial = await ref.read(downloadedLanguagesProvider.future);
      expect(initial, equals(['eng']));

      final gujarati = OcrLanguage.fromCode('guj');
      await ref.read(downloadedLanguagesProvider.notifier).download(gujarati);

      final afterDownload = await ref.read(downloadedLanguagesProvider.future);
      expect(afterDownload, contains('guj'));
      expect(ref.read(activeOcrLanguageProvider).code, equals('guj'));

      await ref.read(downloadedLanguagesProvider.notifier).delete('guj');
      final afterDelete = await ref.read(downloadedLanguagesProvider.future);
      expect(afterDelete.contains('guj'), isFalse);
      expect(ref.read(activeOcrLanguageProvider).code, equals('eng'));
    });
  });
}
