import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/features/scan/domain/document_namer.dart';

void main() {
  group('defaultDocumentName', () {
    test('formats expected default string: docLoom 10 Oct 2026 12-02', () {
      final dt = DateTime(2026, 10, 10, 12, 2);
      expect(defaultDocumentName(dt), equals('docLoom 10 Oct 2026 12-02'));
    });

    test('handles midnight with zero-padded hour and minute', () {
      final dt = DateTime(2026, 10, 10, 0, 0);
      expect(defaultDocumentName(dt), equals('docLoom 10 Oct 2026 00-00'));
    });

    test('zero-pads single-digit hours and single-digit minutes', () {
      final dt = DateTime(2026, 5, 15, 9, 7);
      expect(defaultDocumentName(dt), equals('docLoom 15 May 2026 09-07'));
    });

    test('formats all 12 month names correctly', () {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      for (var m = 1; m <= 12; m++) {
        final dt = DateTime(2026, m, 14, 18, 30);
        expect(
          defaultDocumentName(dt),
          equals('docLoom 14 ${months[m - 1]} 2026 18-30'),
        );
      }
    });
  });
}
