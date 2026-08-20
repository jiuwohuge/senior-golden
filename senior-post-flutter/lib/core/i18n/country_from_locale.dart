import 'package:flutter/material.dart';

import '../bootstrap/app_bootstrap.dart';

/// 注册等场景：按界面语言推断默认国家（须落在 bootstrap 国家列表内）。
String? countryCodeForAppLocale(Locale locale, List<CountryItem> countries) {
  if (countries.isEmpty) return null;
  final lang = locale.languageCode.toLowerCase();
  const fromLang = <String, String>{
    'zh': 'CN',
    'en': 'US',
    'ja': 'JP',
    'ko': 'KR',
    'fr': 'FR',
    'de': 'DE',
    'es': 'ES',
    'it': 'IT',
    'pt': 'PT',
    'ru': 'RU',
  };
  final mapped = fromLang[lang];
  if (mapped != null && countries.any((c) => c.code == mapped)) {
    return mapped;
  }
  final cc = locale.countryCode?.toUpperCase();
  if (cc != null && countries.any((c) => c.code == cc)) {
    return cc;
  }
  return countries.first.code;
}

/// 静默 guest：不依赖 bootstrap 国家表，zh→CN、en→US，缺省 CN。
String countryCodeFromLocale(Locale locale) {
  final lang = locale.languageCode.toLowerCase();
  const fromLang = <String, String>{
    'zh': 'CN',
    'en': 'US',
    'ja': 'JP',
    'ko': 'KR',
    'fr': 'FR',
    'de': 'DE',
    'es': 'ES',
    'it': 'IT',
    'pt': 'PT',
    'ru': 'RU',
  };
  final mapped = fromLang[lang];
  if (mapped != null) return mapped;
  final cc = locale.countryCode?.toUpperCase();
  if (cc != null && cc.length == 2) return cc;
  return 'CN';
}
