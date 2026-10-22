import 'qr_parsed_content.dart';

abstract final class QrContentParser {
  static const _safeSchemes = {'http', 'https', 'tel', 'mailto', 'sms', 'geo'};

  static QrParsedContent parse(String raw) {
    final text = raw.trim();
    if (text.isEmpty) {
      return const PlainTextQrContent(rawText: '', title: 'Empty QR Code');
    }

    final lower = text.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      final uri = Uri.tryParse(text);
      if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
        final host = uri.host.isNotEmpty ? uri.host : text;
        return UrlQrContent(rawText: text, title: host, subtitle: text, openUri: uri);
      }
    }

    if (lower.startsWith('tel:')) {
      final uri = Uri.tryParse(text);
      final phone = text.substring(4);
      return PhoneQrContent(rawText: text, title: phone, subtitle: 'Call $phone', openUri: uri ?? Uri(scheme: 'tel', path: phone));
    }

    if (lower.startsWith('mailto:') || lower.startsWith('matmsg:')) {
      return _parseEmail(text);
    }

    if (lower.startsWith('sms:') || lower.startsWith('smsto:')) {
      return _parseSms(text);
    }

    if (lower.startsWith('geo:')) {
      final uri = Uri.tryParse(text);
      return GeoQrContent(rawText: text, title: 'Coordinates', subtitle: text.substring(4), openUri: uri ?? Uri.parse(text));
    }

    if (lower.startsWith('wifi:')) {
      return _parseWifi(text);
    }

    if (lower.startsWith('begin:vcard')) {
      return _parseVCard(text);
    }

    final uri = Uri.tryParse(text);
    if (uri != null && uri.hasScheme && !_safeSchemes.contains(uri.scheme.toLowerCase())) {
      return PlainTextQrContent(rawText: text, title: 'Blocked Scheme: ${uri.scheme}', subtitle: text);
    }

    return PlainTextQrContent(rawText: text, title: 'Text Note', subtitle: text);
  }

  static EmailQrContent _parseEmail(String text) {
    if (text.toLowerCase().startsWith('mailto:')) {
      final uri = Uri.tryParse(text) ?? Uri(scheme: 'mailto', path: text.substring(7));
      final recipient = uri.path.isNotEmpty ? uri.path : text.substring(7);
      return EmailQrContent(rawText: text, title: recipient, subtitle: text, openUri: uri);
    }
    final to = _extractField(text, 'TO:');
    final sub = _extractField(text, 'SUB:');
    final body = _extractField(text, 'BODY:');
    final uri = Uri(scheme: 'mailto', path: to, queryParameters: {
      if (sub.isNotEmpty) 'subject': sub,
      if (body.isNotEmpty) 'body': body,
    });
    return EmailQrContent(rawText: text, title: to.isNotEmpty ? to : 'Email', subtitle: sub.isNotEmpty ? sub : text, openUri: uri);
  }

  static SmsQrContent _parseSms(String text) {
    final lower = text.toLowerCase();
    final clean = lower.startsWith('smsto:') ? 'sms:${text.substring(6).replaceFirst(':', '?body=')}' : text;
    final uri = Uri.tryParse(clean) ?? Uri(scheme: 'sms', path: text);
    final number = uri.path.isNotEmpty ? uri.path : text;
    return SmsQrContent(rawText: text, title: number, subtitle: text, openUri: uri);
  }

  static WifiQrContent _parseWifi(String text) {
    final ssid = _extractEscaped(text, 'S:');
    final pwd = _extractEscaped(text, 'P:');
    final type = _extractEscaped(text, 'T:');
    final hidden = _extractEscaped(text, 'H:').toLowerCase() == 'true';
    final sec = type.isEmpty ? 'None' : type.toUpperCase();
    return WifiQrContent(rawText: text, title: ssid.isNotEmpty ? ssid : 'Wi-Fi Network', subtitle: 'Security: $sec', ssid: ssid, password: pwd, security: sec, isHidden: hidden);
  }

  static VCardQrContent _parseVCard(String text) {
    String name = '', phone = '', email = '';
    for (final line in text.split(RegExp(r'\r?\n'))) {
      final l = line.trim();
      final upper = l.toUpperCase();
      if (upper.startsWith('FN:')) {
        name = l.substring(3).trim();
      } else if (name.isEmpty && upper.startsWith('N:')) {
        name = l.substring(2).replaceAll(';', ' ').trim();
      } else if (upper.startsWith('TEL')) {
        phone = l.substring(l.indexOf(':') + 1).trim();
      } else if (upper.startsWith('EMAIL')) {
        email = l.substring(l.indexOf(':') + 1).trim();
      }
    }
    return VCardQrContent(rawText: text, title: name.isNotEmpty ? name : 'Contact', subtitle: phone.isNotEmpty ? phone : email, contactPhone: phone.isNotEmpty ? phone : null, contactEmail: email.isNotEmpty ? email : null);
  }

  static String _extractField(String raw, String key) {
    final idx = raw.indexOf(key);
    if (idx < 0) return '';
    final end = raw.indexOf(';', idx);
    return end < 0 ? raw.substring(idx + key.length) : raw.substring(idx + key.length, end);
  }

  static String _extractEscaped(String raw, String key) {
    final idx = raw.indexOf(key);
    if (idx < 0) return '';
    final sb = StringBuffer();
    var i = idx + key.length;
    while (i < raw.length) {
      final ch = raw[i];
      if (ch == '\\' && i + 1 < raw.length) {
        sb.write(raw[i + 1]);
        i += 2;
      } else if (ch == ';') {
        break;
      } else {
        sb.write(ch);
        i++;
      }
    }
    return sb.toString();
  }
}
