import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_locale_provider.dart';
import 'locale_resolution.dart';

/// 磁盘中的语言覆盖（若有）否则使用产品默认英语。
final effectiveAppLocaleProvider = Provider<Locale>((ref) {
  final override = ref.watch(appLocaleProvider);
  return seniorPostEffectiveLocale(override);
});
