import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/core/time/relative_time.dart';

void main() {
  group('relativeTime', () {
    final now = DateTime.utc(2026, 10, 12, 12, 0, 0);

    test('boundary at 59s/60s and singular/plural minutes', () {
      final s59 = now.subtract(const Duration(seconds: 59));
      expect(relativeTime(s59, now), 'Just now');

      final s60 = now.subtract(const Duration(seconds: 60));
      expect(relativeTime(s60, now), '1 minute ago');

      final m2 = now.subtract(const Duration(minutes: 2));
      expect(relativeTime(m2, now), '2 minutes ago');

      final m59 = now.subtract(const Duration(minutes: 59));
      expect(relativeTime(m59, now), '59 minutes ago');
    });

    test('boundary at 23h/24h and singular/plural hours', () {
      final h1 = now.subtract(const Duration(hours: 1));
      expect(relativeTime(h1, now), '1 hour ago');

      final h2 = now.subtract(const Duration(hours: 2));
      expect(relativeTime(h2, now), '2 hours ago');

      final h23 = now.subtract(const Duration(hours: 23, minutes: 59));
      expect(relativeTime(h23, now), '23 hours ago');

      final h24 = now.subtract(const Duration(hours: 24));
      expect(relativeTime(h24, now), 'Yesterday');
    });

    test('boundary at 6d/7d and singular/plural days and weeks', () {
      final d2 = now.subtract(const Duration(days: 2));
      expect(relativeTime(d2, now), '2 days ago');

      final d6 = now.subtract(const Duration(days: 6));
      expect(relativeTime(d6, now), '6 days ago');

      final d7 = now.subtract(const Duration(days: 7));
      expect(relativeTime(d7, now), '1 week ago');

      final w2 = now.subtract(const Duration(days: 14));
      expect(relativeTime(w2, now), '2 weeks ago');

      final w4 = now.subtract(const Duration(days: 28));
      expect(relativeTime(w4, now), '4 weeks ago');
    });

    test('older than 5 weeks falls back to formatted date', () {
      final then = DateTime.utc(2026, 7, 30, 10, 0);
      final local = then.toLocal();
      expect(relativeTime(then, now), '${local.day} Jul ${local.year}');
    });
  });

  group('shortDate and month names', () {
    test('shortDate formats day and month name for all 12 months', () {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      for (var i = 1; i <= 12; i++) {
        final d = DateTime.utc(2026, i, 12);
        expect(shortDate(d), '12 ${months[i - 1]}');
      }
    });
  });
}
