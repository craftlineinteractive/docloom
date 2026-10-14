import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/features/scan/domain/scanned_page.dart';

void main() {
  group('ScannedPage', () {
    test('instantiates with defaults and supports copyWith and equality', () {
      const page1 = ScannedPage(originalPath: '/p1.jpg');
      expect(page1.originalPath, equals('/p1.jpg'));
      expect(page1.editedPath, isNull);
      expect(page1.filterId, equals('original'));
      expect(page1.rotation, equals(0));
      expect(page1.cropJson, isNull);

      final updated = page1.copyWith(
        editedPath: '/p1_edited.jpg',
        rotation: 90,
        filterId: 'bw',
      );
      expect(updated.editedPath, equals('/p1_edited.jpg'));
      expect(updated.rotation, equals(90));
      expect(updated.filterId, equals('bw'));

      const page2 = ScannedPage(originalPath: '/p1.jpg');
      expect(page1, equals(page2));
      expect(page1.hashCode, equals(page2.hashCode));
      expect(page1.toString(), contains('ScannedPage'));
    });
  });
}
