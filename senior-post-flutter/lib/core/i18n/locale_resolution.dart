import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// 英语为产品主语言；在 [supported] 中按设备语言列表优先级匹配，否则回退英语。
Locale resolveSeniorPostLocale(
  List<Locale> deviceLocales,
  Iterable<Locale> supported,
) {
  const english = Locale('en');
  if (deviceLocales.isEmpty) {
    return english;
  }
  final supportedList = supported.toList();

  for (final device in deviceLocales) {
    for (final s in supportedList) {
      if (s.languageCode != device.languageCode) continue;
      if (s.countryCode != null &&
          device.countryCode != null &&
          s.countryCode != device.countryCode) {
        continue;
      }
      return s;
    }
  }

  for (final device in deviceLocales) {
    for (final s in supportedList) {
      if (s.languageCode == device.languageCode) {
        return s;
      }
    }
  }

  return english;
}

/// 与 [AppLocalizations.supportedLocales] 对齐的当前界面语言（设置覆盖 > 默认英语）。
Locale seniorPostEffectiveLocale(Locale? override) {
  if (override != null) {
    return override;
  }
  return const Locale('en');
}

/// HTTP `Accept-Language`，供后端 [MessageSource] 解析。
String acceptLanguageHeader(Locale locale) {
  final cc = locale.countryCode;
  if (cc != null && cc.isNotEmpty) {
    final c = cc.toUpperCase();
    if (locale.languageCode == 'zh') {
      return 'zh-$c';
    }
    return '${locale.languageCode}-$c';
  }
  if (locale.languageCode == 'zh') {
    return 'zh-CN';
  }
  return locale.languageCode;
}
