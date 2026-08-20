/// Tests for countryCodeForAppLocale.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:senior_post_flutter/core/i18n/country_from_locale.dart';
import 'package:senior_post_flutter/core/bootstrap/app_bootstrap.dart';

void main() {
  group('countryCodeForAppLocale', () {
    final countries = <CountryItem>[
      const CountryItem(code: 'CN', nameEn: 'China', nameZh: '中国'),
      const CountryItem(code: 'US', nameEn: 'United States', nameZh: '美国'),
      const CountryItem(code: 'JP', nameEn: 'Japan', nameZh: '日本'),
    ];

    test('zh locale maps to CN', () {
      expect(countryCodeForAppLocale(const Locale('zh'), countries), 'CN');
    });

    test('en locale maps to US', () {
      expect(countryCodeForAppLocale(const Locale('en'), countries), 'US');
    });

    test('ja locale maps to JP', () {
      expect(countryCodeForAppLocale(const Locale('ja'), countries), 'JP');
    });

    test('unknown language falls back to first country', () {
      expect(countryCodeForAppLocale(const Locale('fr'), countries), 'CN');
    });

    test('empty countries returns null', () {
      expect(countryCodeForAppLocale(const Locale('en'), <CountryItem>[]), isNull);
    });

    test('locale with countryCode falls back to language map', () {
      expect(countryCodeForAppLocale(const Locale('zh', 'HK'), countries), 'CN');
    });
  });

  group('countryCodeFromLocale', () {
    test('zh maps to CN without bootstrap list', () {
      expect(countryCodeFromLocale(const Locale('zh')), 'CN');
    });

    test('en maps to US', () {
      expect(countryCodeFromLocale(const Locale('en', 'GB')), 'US');
    });
  });
}
