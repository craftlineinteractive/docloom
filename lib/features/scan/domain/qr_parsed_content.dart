enum QrContentType {
  url,
  phone,
  email,
  sms,
  geo,
  wifi,
  vCard,
  plainText,
}

sealed class QrParsedContent {
  const QrParsedContent({
    required this.rawText,
    required this.type,
    required this.title,
    this.subtitle,
    this.canOpen = false,
    this.openUri,
  });

  final String rawText;
  final QrContentType type;
  final String title;
  final String? subtitle;
  final bool canOpen;
  final Uri? openUri;

  String get typeLabel => switch (type) {
        QrContentType.url => 'Website Link',
        QrContentType.phone => 'Phone Number',
        QrContentType.email => 'Email Address',
        QrContentType.sms => 'SMS Message',
        QrContentType.geo => 'Location',
        QrContentType.wifi => 'Wi-Fi Network',
        QrContentType.vCard => 'Contact Card',
        QrContentType.plainText => 'Plain Text',
      };
}

final class UrlQrContent extends QrParsedContent {
  const UrlQrContent({
    required super.rawText,
    required super.title,
    super.subtitle,
    required Uri openUri,
  }) : super(type: QrContentType.url, canOpen: true, openUri: openUri);
}

final class PhoneQrContent extends QrParsedContent {
  const PhoneQrContent({
    required super.rawText,
    required super.title,
    super.subtitle,
    required Uri openUri,
  }) : super(type: QrContentType.phone, canOpen: true, openUri: openUri);
}

final class EmailQrContent extends QrParsedContent {
  const EmailQrContent({
    required super.rawText,
    required super.title,
    super.subtitle,
    required Uri openUri,
  }) : super(type: QrContentType.email, canOpen: true, openUri: openUri);
}

final class SmsQrContent extends QrParsedContent {
  const SmsQrContent({
    required super.rawText,
    required super.title,
    super.subtitle,
    required Uri openUri,
  }) : super(type: QrContentType.sms, canOpen: true, openUri: openUri);
}

final class GeoQrContent extends QrParsedContent {
  const GeoQrContent({
    required super.rawText,
    required super.title,
    super.subtitle,
    required Uri openUri,
  }) : super(type: QrContentType.geo, canOpen: true, openUri: openUri);
}

final class WifiQrContent extends QrParsedContent {
  const WifiQrContent({
    required super.rawText,
    required super.title,
    super.subtitle,
    required this.ssid,
    required this.password,
    required this.security,
    required this.isHidden,
  }) : super(type: QrContentType.wifi, canOpen: false);

  final String ssid;
  final String password;
  final String security;
  final bool isHidden;
}

final class VCardQrContent extends QrParsedContent {
  const VCardQrContent({
    required super.rawText,
    required super.title,
    super.subtitle,
    this.contactPhone,
    this.contactEmail,
  }) : super(type: QrContentType.vCard, canOpen: false);

  final String? contactPhone;
  final String? contactEmail;
}

final class PlainTextQrContent extends QrParsedContent {
  const PlainTextQrContent({
    required super.rawText,
    required super.title,
    super.subtitle,
  }) : super(type: QrContentType.plainText, canOpen: false);
}
