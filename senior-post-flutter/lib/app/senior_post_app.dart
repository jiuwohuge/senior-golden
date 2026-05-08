import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../core/auth/auth_token.dart';
import '../core/i18n/app_locale_provider.dart';
import '../core/network/router_refresh.dart';
import 'router/app_router.dart';
import 'theme/postal_theme.dart';

/// 根应用：邮政主题、适老化字号、国际化（英语优先 + 跟随系统语言列表）。
class SeniorPostApp extends ConsumerWidget {
  const SeniorPostApp({super.key});

  /// 英语为产品主语言；系统语言列表按优先级匹配 `supportedLocales`，否则回退英语。
  static Locale _resolveLocale(
    List<Locale>? deviceLocales,
    Iterable<Locale> supported,
  ) {
    const english = Locale('en');
    if (deviceLocales == null || deviceLocales.isEmpty) {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<String?>(authTokenProvider, (previous, next) {
      ref.read(routerRefreshProvider).value++;
    });

    final router = ref.watch(appRouterProvider);
    final localeOverride = ref.watch(appLocaleProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: PostalTheme.light(),
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: localeOverride,
      localeListResolutionCallback: localeOverride != null
          ? null
          : (deviceLocales, supported) =>
              _resolveLocale(deviceLocales, supported),
    );
  }
}
