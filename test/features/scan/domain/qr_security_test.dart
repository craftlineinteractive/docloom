import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/features/scan/domain/qr_content_parser.dart';
import 'package:docloom/features/scan/domain/qr_parsed_content.dart';

void main() {
  group('QrContentParser Security & Unsafe Schemes', () {
    test('blocks javascript: URI scheme', () {
      final res = QrContentParser.parse('javascript:alert(document.cookie)');
      expect(res, isA<PlainTextQrContent>());
      expect(res.canOpen, isFalse);
      expect(res.openUri, isNull);
    });

    test('blocks file: URI scheme', () {
      final res = QrContentParser.parse('file:///etc/passwd');
      expect(res, isA<PlainTextQrContent>());
      expect(res.canOpen, isFalse);
      expect(res.openUri, isNull);
    });

    test('blocks intent: URI scheme', () {
      final res = QrContentParser.parse('intent://scan/#Intent;scheme=zxing;package=com.google.zxing.client.android;end');
      expect(res, isA<PlainTextQrContent>());
      expect(res.canOpen, isFalse);
      expect(res.openUri, isNull);
    });

    test('blocks data: and blob: schemes', () {
      final dataRes = QrContentParser.parse('data:text/html;base64,PHNjcmlwdD5hbGVydCgxKTwvc2NyaXB0Pg==');
      expect(dataRes, isA<PlainTextQrContent>());
      expect(dataRes.canOpen, isFalse);

      final blobRes = QrContentParser.parse('blob:https://example.com/uuid');
      expect(blobRes, isA<PlainTextQrContent>());
      expect(blobRes.canOpen, isFalse);
    });

    test('handles empty and whitespace strings safely', () {
      final emptyRes = QrContentParser.parse('');
      expect(emptyRes, isA<PlainTextQrContent>());
      expect(emptyRes.canOpen, isFalse);

      final wsRes = QrContentParser.parse('   \n\t  ');
      expect(wsRes, isA<PlainTextQrContent>());
      expect(wsRes.canOpen, isFalse);
    });

    test('plain text notes are not openable', () {
      final res = QrContentParser.parse('Just a simple shopping list note');
      expect(res, isA<PlainTextQrContent>());
      expect(res.canOpen, isFalse);
      expect(res.openUri, isNull);
    });
  });
}
