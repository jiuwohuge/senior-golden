/// Tests for directory providers: DirectoryFilter state management.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:senior_post_flutter/features/directory/directory_providers.dart';

void main() {
  group('DirectoryFilter defaults', () {
    test('default filter minAge is 45', () {
      const f = DirectoryFilter();
      expect(f.minAge, 45);
    });

    test('default filter maxAge is 80', () {
      const f = DirectoryFilter();
      expect(f.maxAge, 80);
    });

    test('default sort is DEFAULT', () {
      const f = DirectoryFilter();
      expect(f.sort, 'DEFAULT');
    });

    test('interests and genders are empty sets', () {
      const f = DirectoryFilter();
      expect(f.interests, {});
      expect(f.genders, {});
    });

    test('countryCode is null by default', () {
      const f = DirectoryFilter();
      expect(f.countryCode, isNull);
    });
  });

  group('DirectoryFilter copyWith', () {
    test('overrides countryCode', () {
      const f = DirectoryFilter();
      final f2 = f.copyWith(countryCode: 'CN');
      expect(f2.countryCode, 'CN');
      expect(f2.minAge, 45); // unchanged
    });

    test('overrides interests', () {
      const f = DirectoryFilter();
      final f2 = f.copyWith(interests: {'reading', 'music'});
      expect(f2.interests, {'reading', 'music'});
      expect(f2.genders, {});
    });

    test('overrides sort', () {
      const f = DirectoryFilter();
      final f2 = f.copyWith(sort: 'CLOSEST_AGE');
      expect(f2.sort, 'CLOSEST_AGE');
    });

    test('complete chain', () {
      const f = DirectoryFilter(minAge: 50, maxAge: 70);
      final f2 = f.copyWith(
        countryCode: 'US',
        minAge: 55,
        maxAge: 75,
        genders: {1, 2},
      );
      expect(f2.countryCode, 'US');
      expect(f2.minAge, 55);
      expect(f2.maxAge, 75);
      expect(f2.genders, {1, 2});
      expect(f2.sort, 'DEFAULT');
    });
  });
}
