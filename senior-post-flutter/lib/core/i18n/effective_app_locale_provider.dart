import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_locale_provider.dart';
import 'locale_resolution.dart';

/// 设置覆盖优先；否则跟随设备语言（再回退英语）。
final effectiveAppLocaleProvider = Provider<Locale>((ref) {
  final override = ref.watch(appLocaleProvider);
  return seniorPostEffectiveLocale(
    override,
    deviceLocales: WidgetsBinding.instance.platformDispatcher.locales,
  );
});
