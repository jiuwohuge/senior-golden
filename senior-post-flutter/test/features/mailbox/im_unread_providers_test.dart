/// Tests for im_unread_providers: foldImC2cUnreadTotal.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:senior_post_flutter/features/mailbox/im_unread_providers.dart';

void main() {
  group('foldImC2cUnreadTotal', () {
    test('returns 0 for empty map', () {
      expect(foldImC2cUnreadTotal({}), 0);
    });

    test('sums single entry', () {
      expect(foldImC2cUnreadTotal({'user1': 5}), 5);
    });

    test('sums multiple entries', () {
      expect(foldImC2cUnreadTotal({'u1': 3, 'u2': 7, 'u3': 0}), 10);
    });

    test('handles large values', () {
      expect(foldImC2cUnreadTotal({'a': 99, 'b': 1}), 100);
    });
  });
}
