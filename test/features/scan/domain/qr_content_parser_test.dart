import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/features/scan/domain/qr_content_parser.dart';
import 'package:docloom/features/scan/domain/qr_parsed_content.dart';

void main() {
  group('QrContentParser', () {
    test('parses https and http URLs correctly with canOpen=true', () {
      final res = QrContentParser.parse('https://example.com/path?arg=1');
      expect(res, isA<UrlQrContent>());
      expect(res.canOpen, isTrue);
      expect(res.title, 'example.com');
      expect(res.openUri, Uri.parse('https://example.com/path?arg=1'));

      final httpRes = QrContentParser.parse('http://docloom.app');
      expect(httpRes, isA<UrlQrContent>());
      expect(httpRes.canOpen, isTrue);
    });

    test('parses tel scheme correctly', () {
      final res = QrContentParser.parse('tel:+15551234567');
      expect(res, isA<PhoneQrContent>());
      expect(res.canOpen, isTrue);
      expect(res.title, '+15551234567');
    });

    test('parses mailto and matmsg email formats', () {
      final mailto = QrContentParser.parse('mailto:support@docloom.app');
      expect(mailto, isA<EmailQrContent>());
      expect(mailto.canOpen, isTrue);
      expect(mailto.title, 'support@docloom.app');

      final matmsg = QrContentParser.parse('MATMSG:TO:dev@docloom.app;SUB:Help;BODY:Test;;');
      expect(matmsg, isA<EmailQrContent>());
      expect(matmsg.canOpen, isTrue);
      expect(matmsg.title, 'dev@docloom.app');
    });

    test('parses sms and smsto formats', () {
      final sms = QrContentParser.parse('sms:+1234567890');
      expect(sms, isA<SmsQrContent>());
      expect(sms.canOpen, isTrue);

      final smsto = QrContentParser.parse('SMSTO:+1234567890:Hello');
      expect(smsto, isA<SmsQrContent>());
      expect(smsto.canOpen, isTrue);
    });

    test('parses geo coordinates', () {
      final geo = QrContentParser.parse('geo:37.7749,-122.4194');
      expect(geo, isA<GeoQrContent>());
      expect(geo.canOpen, isTrue);
    });

    test('parses standard Wi-Fi configuration', () {
      final wifi = QrContentParser.parse('WIFI:T:WPA;S:HomeNetwork;P:Secret123;H:false;;');
      expect(wifi, isA<WifiQrContent>());
      final w = wifi as WifiQrContent;
      expect(w.ssid, 'HomeNetwork');
      expect(w.password, 'Secret123');
      expect(w.security, 'WPA');
      expect(w.isHidden, isFalse);
      expect(w.canOpen, isFalse);
    });

    test('parses Wi-Fi with escaped characters', () {
      final wifi = QrContentParser.parse(r'WIFI:T:WPA2;S:My\;Office\;Net;P:P\@ss\:word\\;H:true;;');
      expect(wifi, isA<WifiQrContent>());
      final w = wifi as WifiQrContent;
      expect(w.ssid, 'My;Office;Net');
      expect(w.password, r'P@ss:word\');
      expect(w.security, 'WPA2');
      expect(w.isHidden, isTrue);
    });

    test('parses vCard contact information', () {
      const vcard = '''BEGIN:VCARD
VERSION:3.0
FN:Jane Doe
TEL:+14155552671
EMAIL:jane@example.com
END:VCARD''';
      final res = QrContentParser.parse(vcard);
      expect(res, isA<VCardQrContent>());
      final v = res as VCardQrContent;
      expect(v.title, 'Jane Doe');
      expect(v.contactPhone, '+14155552671');
      expect(v.contactEmail, 'jane@example.com');
      expect(v.canOpen, isFalse);
    });
  });
}
