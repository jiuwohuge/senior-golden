import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../app/theme/postal_tokens.dart';
import '../../core/auth/auth_launch_pref.dart';
import '../../core/auth/auth_token.dart';
import '../../core/device/location_access.dart';
import '../../core/device/location_bootstrap.dart';
import '../../core/network/router_refresh.dart';
import '../../widgets/postal/postal.dart';
import '../auth/auth_repository.dart';
import '../auth/login_routes.dart';
import '../shell/main_shell.dart';

/// 冷启动门控：先弹出系统定位授权（允许或拒绝），再静默 guest / 进入邮局。
class LocationBootstrapPage extends ConsumerStatefulWidget {
  const LocationBootstrapPage({super.key});

  static const path = '/boot';

  @override
  ConsumerState<LocationBootstrapPage> createState() =>
      _LocationBootstrapPageState();
}

class _LocationBootstrapPageState extends ConsumerState<LocationBootstrapPage> {
  var _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    if (_started) {
      return;
    }
    _started = true;
    try {
      if (mounted) {
        await ref.read(locationAccessProvider).ensureAsked(
              context: context,
              reason: LocationPromptReason.bootstrap,
            );
      }
      final token = ref.read(authTokenProvider);
      if (token == null || token.isEmpty) {
        final skipGuest = await AuthLaunchPref.skipSilentGuest();
        if (!skipGuest) {
          try {
            await ref.read(authRepositoryProvider).guest();
          } catch (e) {
            debugPrint('startup guest auth failed: $e');
          }
        }
      } else {
        await ref.read(locationAccessProvider).syncToServerIfPossible();
      }
    } catch (e) {
      debugPrint('location bootstrap failed: $e');
    }
    ref.read(locationBootstrapDoneProvider.notifier).state = true;
    ref.read(routerRefreshProvider).value++;
    if (!mounted) {
      return;
    }
    final loggedIn = (ref.read(authTokenProvider) ?? '').isNotEmpty;
    context.go(
      loggedIn ? MainShellRoute.pathPostOffice : LoginRoutes.login,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: PostalTokens.paperCream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),
              PostalBrandHeader(
                title: l10n.appTitle,
                tagline: l10n.locationBootstrapTagline,
              ),
              const SizedBox(height: 36),
              Text(
                l10n.locationBootstrapHint,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: PostalTokens.inkSecondary,
                  height: 1.5,
                  fontSize: 18,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.location_on_outlined,
                size: 28,
                color: PostalTokens.postboxGreen,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.locationBootstrapWait,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: PostalTokens.inkTertiary,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
