import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../app/theme/postal_tokens.dart';
import '../../core/api/api_exception.dart';
import '../../core/auth/google_sign_in_facade.dart';
import '../../widgets/postal/postal.dart';
import '../../widgets/postal/postal_legal_footnote.dart';
import '../shell/main_shell.dart';
import 'auth_consent_provider.dart';
import 'auth_repository.dart';
import 'login_routes.dart';

/// 未登录首页：参考简洁落地页 — 品牌 + 胶囊主按钮（非通栏）+ 页脚协议。
class AuthWelcomePage extends ConsumerStatefulWidget {
  const AuthWelcomePage({super.key});

  @override
  ConsumerState<AuthWelcomePage> createState() => _AuthWelcomePageState();
}

class _AuthWelcomePageState extends ConsumerState<AuthWelcomePage> {
  bool _busy = false;

  /// Google 登录仅 Android 正式渠道；Web 联调隐藏入口。
  bool get _showGoogle =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  void _acceptTermsAndProceed(VoidCallback action) {
    ref.read(authConsentProvider.notifier).state = true;
    action();
  }

  Future<void> _afterAuth(AuthSignInResult result) async {
    if (!mounted) return;
    if (result.profileComplete == false) {
      context.go(LoginRoutes.socialComplete);
      return;
    }
    context.go(MainShellRoute.pathPostOffice);
  }

  Future<void> _signInWithGoogle() async {
    final l10n = AppLocalizations.of(context)!;
    if (!GoogleSignInFacade.isConfigured) {
      PostalSnack.show(
        context,
        l10n.authGoogleNotConfigured,
        tone: PostalSnackTone.warning,
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final idToken = await GoogleSignInFacade.signIn();
      if (idToken == null || idToken.isEmpty) {
        if (mounted) setState(() => _busy = false);
        return;
      }
      final result = await ref
          .read(authRepositoryProvider)
          .signInWithGoogle(idToken: idToken);
      await _afterAuth(result);
    } on ApiBusinessException catch (e) {
      if (mounted) {
        PostalSnack.show(context, e.message, tone: PostalSnackTone.error);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final laneW = (MediaQuery.sizeOf(context).width * 0.84).clamp(260.0, 340.0);

    final actions = SizedBox(
      width: laneW,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_showGoogle) ...[
            PostalButton(
              label: l10n.authContinueWithGoogle,
              icon: Icons.g_mobiledata_rounded,
              pill: true,
              minHeight: 54,
              busy: _busy,
              onPressed: _busy
                  ? null
                  : () => _acceptTermsAndProceed(_signInWithGoogle),
              variant: PostalButtonVariant.danger,
            ),
            const SizedBox(height: 12),
          ],
          PostalButton(
            label: l10n.authWelcomeRegister,
            pill: true,
            minHeight: 54,
            busy: _busy,
            onPressed: _busy
                ? null
                : () => _acceptTermsAndProceed(
                    () => context.go(LoginRoutes.register),
                  ),
          ),
          const SizedBox(height: 28),
          Text(
            l10n.authWelcomeHaveAccount,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: PostalTokens.inkTertiary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          PostalButton(
            label: l10n.authWelcomeLogin,
            pill: true,
            minHeight: 50,
            onPressed: _busy ? null : () => context.go(LoginRoutes.login),
            variant: PostalButtonVariant.secondary,
          ),
        ],
      ),
    );

    final footer = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: PostalLegalFootnote(
        template: l10n.authWelcomeLegalFooter('{terms}', '{privacy}'),
        linkSegments: [
          PostalLinkSegment(
            key: 'terms',
            text: l10n.authTermsTitle,
            onTap: () => context.go(LoginRoutes.legalTerms),
          ),
          PostalLinkSegment(
            key: 'privacy',
            text: l10n.authPrivacyTitle,
            onTap: () => context.go(LoginRoutes.legalPrivacy),
          ),
        ],
      ),
    );

    return Scaffold(
      body: PaperTextureBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // ScrollView 内不能用 Expanded/Spacer，否则会 hit-test 未 layout 的 RenderBox。
              final h = constraints.maxHeight;
              final useScroll = h < 520;

              final column = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: (h * 0.08).clamp(16.0, 56.0)),
                  _WelcomeBrand(title: l10n.appTitle, tagline: l10n.appTagline),
                  if (useScroll) const SizedBox(height: 32) else const Spacer(),
                  Center(child: actions),
                  if (useScroll) const SizedBox(height: 32) else const Spacer(),
                  footer,
                  const SizedBox(height: 8),
                ],
              );

              if (!useScroll) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 12,
                  ),
                  child: column,
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 20,
                ),
                child: column,
              );
            },
          ),
        ),
      ),
    );
  }
}

/// 欢迎页品牌区：比 [PostalBrandHeader] 更紧凑。
class _WelcomeBrand extends StatelessWidget {
  const _WelcomeBrand({required this.title, required this.tagline});

  final String title;
  final String tagline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        PostmarkRing(
          size: 64,
          strokeWidth: 1.4,
          color: PostalTokens.postboxGreen.withValues(alpha: 0.45),
          year: '2026',
        ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: PostalTokens.inkNavy,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        Container(width: 48, height: 1.2, color: PostalTokens.stampVermilion),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            tagline,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: PostalTokens.inkSecondary,
              fontStyle: FontStyle.italic,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}
