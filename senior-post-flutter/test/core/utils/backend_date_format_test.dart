/// Tests for backend date format helpers.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:senior_post_flutter/core/time/backend_date_format.dart';

void main() {
  group('formatBackendLocalDate', () {
    test('formats 2026-01-05 as 01-05-2026', () {
      final dt = DateTime(2026, 1, 5);
      expect(formatBackendLocalDate(dt), '01-05-2026');
    });

    test('formats 2025-12-31 as 12-31-2025', () {
      final dt = DateTime(2025, 12, 31);
      expect(formatBackendLocalDate(dt), '12-31-2025');
    });
  });

  group('parseBackendLocalDate', () {
    test('parses valid date string', () {
      final dt = parseBackendLocalDate('06-15-2026');
      expect(dt, isNotNull);
      expect(dt!.year, 2026);
      expect(dt.month, 6);
      expect(dt.day, 15);
    });

    test('returns null for null input', () {
      expect(parseBackendLocalDate(null), isNull);
    });

    test('returns null for non-string input', () {
      expect(parseBackendLocalDate(123), isNull);
    });

    test('returns null for empty string', () {
      expect(parseBackendLocalDate(''), isNull);
    });

    test('falls back to DateTime.tryParse for ISO format', () {
      final dt = parseBackendLocalDate('2026-07-01T12:00:00Z');
      expect(dt, isNotNull);
      expect(dt!.year, 2026);
    });
  });
}
