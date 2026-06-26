/// Mock AppLocalizations delegate for Widget tests using mocktail.
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';
import 'mock_localizations.dart';

class MockLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const MockLocalizationsDelegate(this.l10n);
  final MockAppLocalizations l10n;

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'en' || locale.languageCode == 'zh';

  @override
  Future<AppLocalizations> load(Locale locale) async => l10n;

  @override
  bool shouldReload(MockLocalizationsDelegate old) => false;
}
