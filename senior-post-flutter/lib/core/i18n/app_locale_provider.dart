import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocalePref = 'app_locale_override';

/// `null`：跟随系统（由 [SeniorPostApp] 的 resolution 决定）；非 null：强制界面语言。
final appLocaleProvider = StateNotifierProvider<AppLocaleNotifier, Locale?>((
  ref,
) {
  return AppLocaleNotifier();
});

class AppLocaleNotifier extends StateNotifier<Locale?> {
  AppLocaleNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_kLocalePref);
    if (raw == null || raw.isEmpty || raw == 'system') {
      state = null;
      return;
    }
    final parts = raw.split('_');
    final lang = parts.first;
    final country = parts.length > 1 && parts[1].isNotEmpty ? parts[1] : null;
    state = Locale(lang, country);
  }

  /// [locale] 为 null 表示恢复「跟随系统」。
  Future<void> setLocale(Locale? locale) async {
    final p = await SharedPreferences.getInstance();
    if (locale == null) {
      await p.setString(_kLocalePref, 'system');
      state = null;
      return;
    }
    await p.setString(
      _kLocalePref,
      locale.countryCode != null && locale.countryCode!.isNotEmpty
          ? '${locale.languageCode}_${locale.countryCode}'
          : locale.languageCode,
    );
    state = locale;
  }
}
