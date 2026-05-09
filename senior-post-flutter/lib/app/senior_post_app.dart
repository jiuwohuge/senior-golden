import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../core/auth/auth_token.dart';
import '../core/i18n/app_locale_provider.dart';
import '../core/i18n/locale_resolution.dart';
import '../core/network/router_refresh.dart';
import '../features/auth/auth_repository.dart';
import 'router/app_router.dart';
import 'theme/postal_theme.dart';

/// 根应用：邮政主题、适老化字号、国际化（英语优先 + 跟随系统语言列表）。
class SeniorPostApp extends ConsumerWidget {
  const SeniorPostApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<String?>(authTokenProvider, (previous, next) {
      ref.read(routerRefreshProvider).value++;
      if (next != null && next.isNotEmpty) {
        Future.microtask(() async {
          try {
            await ref.read(authRepositoryProvider).refreshSessionFromServer();
          } catch (_) {}
        });
      }
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
                resolveSeniorPostLocale(deviceLocales ?? const [], supported),
    );
  }
}
