import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/features/ocr/domain/ocr_language.dart';

void main() {
  group('OcrLanguage', () {
    test('contains 27 languages in total', () {
      expect(OcrLanguage.all.length, equals(27));
    });

    test('English is the default and only bundled language', () {
      expect(OcrLanguage.defaultLanguage.code, equals('eng'));
      expect(OcrLanguage.defaultLanguage.isBundled, isTrue);

      final bundled = OcrLanguage.all.where((l) => l.isBundled).toList();
      expect(bundled.length, equals(1));
      expect(bundled.first.code, equals('eng'));
    });

    test('contains 13 Indian languages', () {
      final indian = OcrLanguage.all.where((l) => l.isIndian).toList();
      expect(indian.length, equals(13));
      final codes = indian.map((l) => l.code).toSet();
      expect(codes, containsAll([
        'hin', 'guj', 'mar', 'tam', 'tel', 'kan', 'mal',
        'ben', 'pan', 'ori', 'asm', 'urd', 'san',
      ]));
    });

    test('contains 13 international non-bundled languages', () {
      final globalNonBundled = OcrLanguage.all.where((l) => !l.isIndian && !l.isBundled).toList();
      expect(globalNonBundled.length, equals(13));
      final codes = globalNonBundled.map((l) => l.code).toSet();
      expect(codes, containsAll([
        'spa', 'fra', 'deu', 'ara', 'por', 'rus', 'ita',
        'tur', 'ind', 'vie', 'chi_sim', 'jpn', 'kor',
      ]));
    });

    test('fromCode returns correct language or defaults to English', () {
      expect(OcrLanguage.fromCode('guj').name, equals('Gujarati'));
      expect(OcrLanguage.fromCode('hin').nativeName, equals('हिन्दी'));
      expect(OcrLanguage.fromCode('jpn').name, equals('Japanese'));
      expect(OcrLanguage.fromCode('unknown_xyz').code, equals('eng'));
    });
  });
}
