import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import 'app_locale_provider.dart';
import 'locale_resolution.dart';

/// 磁盘中的语言覆盖（若有）否则按系统语言解析为 [AppLocalizations] 之一。
final effectiveAppLocaleProvider = Provider<Locale>((ref) {
  final override = ref.watch(appLocaleProvider);
  return seniorPostEffectiveLocale(override);
});
