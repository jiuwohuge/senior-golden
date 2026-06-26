/// Tests for locale resolution logic (pure function, no WidgetsBinding).
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:senior_post_flutter/core/i18n/locale_resolution.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

void main() {
  group('resolveSeniorPostLocale', () {
    test('returns English when device list is empty', () {
      final result = resolveSeniorPostLocale([], AppLocalizations.supportedLocales);
      expect(result, const Locale('en'));
    });

    test('matches exact language + country', () {
      final device = [const Locale('zh', 'CN')];
      final result = resolveSeniorPostLocale(device, AppLocalizations.supportedLocales);
      expect(result.languageCode, 'zh');
    });

    test('matches language-only fallback', () {
      final device = [const Locale.fromSubtags(languageCode: 'zh')];
      final result = resolveSeniorPostLocale(device, AppLocalizations.supportedLocales);
      expect(result.languageCode, 'zh');
    });

    test('falls back to English for unsupported language', () {
      final device = [const Locale('fr')];
      final result = resolveSeniorPostLocale(device, AppLocalizations.supportedLocales);
      expect(result, const Locale('en'));
    });

    test('prefers first device locale match', () {
      // List has Chinese first, French second.
      final device = [const Locale('zh'), const Locale('fr')];
      final result = resolveSeniorPostLocale(device, AppLocalizations.supportedLocales);
      expect(result.languageCode, 'zh');
    });
  });

  group('acceptLanguageHeader', () {
    test('zh-CN produces zh-CN', () {
      expect(acceptLanguageHeader(const Locale('zh', 'CN')), 'zh-CN');
    });

    test('zh without country produces zh-CN', () {
      expect(acceptLanguageHeader(const Locale('zh')), 'zh-CN');
    });

    test('en produces en', () {
      expect(acceptLanguageHeader(const Locale('en')), 'en');
    });

    test('en-US produces en-US', () {
      expect(acceptLanguageHeader(const Locale('en', 'US')), 'en-US');
    });
  });
}
