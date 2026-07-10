import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../core/auth/auth_data_refresh.dart';
import '../core/auth/auth_token.dart';
import '../core/i18n/app_locale_provider.dart';
import '../core/i18n/locale_resolution.dart';
import '../core/network/router_refresh.dart';
import '../features/auth/auth_repository.dart';
import '../features/startup/release_note_layer.dart';
import '../features/push/push_service.dart';
import 'router/app_router.dart';
import 'theme/postal_theme.dart';

/// 根应用：邮政主题、适老化字号、国际化（默认跟随设备，设置可覆盖）。
class SeniorPostApp extends ConsumerWidget {
  const SeniorPostApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<String?>(authTokenProvider, (previous, next) {
      ref.read(routerRefreshProvider).value++;
      if (previous != next) {
        ref.read(invalidateAuthDataProvider)();
      }
      if (next != null && next.isNotEmpty) {
        Future.microtask(() async {
          try {
            await ref.read(authRepositoryProvider).refreshSessionFromServer();
          } catch (_) {}
          try {
            await ensurePushTokenRegistered(ref);
          } catch (_) {}
          ref.invalidate(releaseNoteFetchProvider);
        });
      }
    });

    final router = ref.watch(appRouterProvider);
    final localeOverride = ref.watch(appLocaleProvider);
    // 无设置覆盖时按设备语言解析；覆盖仅作测试/偏好开关
    final resolvedLocale = seniorPostEffectiveLocale(
      localeOverride,
      deviceLocales: WidgetsBinding.instance.platformDispatcher.locales,
    );

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: PostalTheme.light(),
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: resolvedLocale,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: media.textScaler.clamp(
              minScaleFactor: 1.0,
              maxScaleFactor: 2.0,
            ),
          ),
          child: Stack(
            children: [if (child != null) child, const ReleaseNoteLayer()],
          ),
        );
      },
    );
  }
}
