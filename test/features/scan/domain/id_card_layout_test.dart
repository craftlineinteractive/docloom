import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/features/scan/domain/id_card_layout.dart';

void main() {
  group('IdCardLayout', () {
    test('constants define centered A4 card dimensions', () {
      expect(IdCardLayout.a4Width, equals(2480));
      expect(IdCardLayout.a4Height, equals(3508));
      expect(IdCardLayout.cardWidth, equals(1011));
      expect(IdCardLayout.cardHeight, equals(638));
      expect(IdCardLayout.leftMargin, equals(734));
      expect(IdCardLayout.frontTop, equals(500));
      expect(IdCardLayout.cardGap, equals(200));
      expect(IdCardLayout.backTop, equals(1338));

      // Verify geometry relationships
      expect(IdCardLayout.leftMargin * 2 + IdCardLayout.cardWidth, equals(IdCardLayout.a4Width - 1));
      expect(IdCardLayout.backTop, equals(IdCardLayout.frontTop + IdCardLayout.cardHeight + IdCardLayout.cardGap));
    });
  });
}
