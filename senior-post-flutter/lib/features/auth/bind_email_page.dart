import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../app/theme/postal_tokens.dart';
import '../../core/api/api_exception.dart';
import '../../core/auth/google_sign_in_facade.dart';
import '../../core/models/domain_models.dart';
import '../../core/session/app_session.dart';
import '../../widgets/postal/postal.dart';
import '../shell/main_shell.dart';
import 'auth_repository.dart';

enum _BindMethod { email, google }

/// 访客绑定或更换登录身份：邮箱（验证码）或 Google openId，不走 8 步注册、不新建用户。
class BindEmailPage extends ConsumerStatefulWidget {
  const BindEmailPage({super.key});

  @override
  ConsumerState<BindEmailPage> createState() => _BindEmailPageState();
}

class _BindEmailPageState extends ConsumerState<BindEmailPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _code = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _busy = false;
  bool _sendingCode = false;
  int _cooldown = 0;
  Timer? _cooldownTimer;
  _BindMethod _method = _BindMethod.email;

  bool get _showGoogle => true;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _email.dispose();
    _password.dispose();
    _code.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _cooldown = 60);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_cooldown <= 1) {
        t.cancel();
        setState(() => _cooldown = 0);
        return;
      }
      setState(() => _cooldown -= 1);
    });
  }

  Future<void> _sendCode() async {
    final l10n = AppLocalizations.of(context)!;
    final email = _email.text.trim();
    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      PostalSnack.show(
        context,
        l10n.authEmailInvalid,
        tone: PostalSnackTone.warning,
      );
      return;
    }
    setState(() => _sendingCode = true);
    try {
      await ref.read(authRepositoryProvider).sendBindEmailCode(email: email);
      if (!mounted) return;
      _startCooldown();
      PostalSnack.show(
        context,
        l10n.bindCodeSent,
        tone: PostalSnackTone.success,
      );
    } on ApiBusinessException catch (e) {
      debugPrint('bind email send-code failed: $e');
      if (mounted) {
        PostalSnack.show(context, e.message, tone: PostalSnackTone.error);
      }
    } catch (e) {
      debugPrint('bind email send-code failed: $e');
      if (mounted) {
        PostalSnack.show(context, e.toString(), tone: PostalSnackTone.error);
      }
    } finally {
      if (mounted) setState(() => _sendingCode = false);
    }
  }

  Future<void> _submitEmail() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final wasBound = ref.read(appSessionProvider).user.bound;
    setState(() => _busy = true);
    try {
      await ref.read(authRepositoryProvider).bindEmail(
        email: _email.text,
        password: _password.text,
        code: _code.text,
      );
      if (!mounted) return;
      await _showBoundTipAndLeave(changed: wasBound);
    } on ApiBusinessException catch (e) {
      debugPrint('bind email failed: $e');
      if (mounted) {
        PostalSnack.show(context, e.message, tone: PostalSnackTone.error);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submitGoogle() async {
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
      final wasBound = ref.read(appSessionProvider).user.bound;
      await ref.read(authRepositoryProvider).bindGoogle(idToken: idToken);
      if (!mounted) return;
      await _showBoundTipAndLeave(changed: wasBound);
    } on ApiBusinessException catch (e) {
      debugPrint('bind google failed: $e');
      if (mounted) {
        PostalSnack.show(context, e.message, tone: PostalSnackTone.error);
      }
    } catch (e) {
      debugPrint('bind google failed: $e');
      if (mounted) {
        PostalSnack.show(context, e.toString(), tone: PostalSnackTone.error);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _showBoundTipAndLeave({required bool changed}) async {
    final l10n = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: Icon(
          Icons.markunread_mailbox_outlined,
          color: PostalTokens.postboxGreen,
          size: 48,
        ),
        title: Text(
          changed ? l10n.bindSuccessChangeTitle : l10n.bindSuccessTitle,
        ),
        content: Text(
          changed ? l10n.bindSuccessChangeBody : l10n.bindSuccessBody,
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.bindSuccessOk),
          ),
        ],
      ),
    );
    if (!mounted) return;
    // 从「我的」进入则回到资料页；从写信后引导进入则回邮局。
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(MainShellRoute.pathPostOffice);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(appSessionProvider).user;
    final bound = user.bound;
    final canBind = user.canBind;
    final title = !canBind
        ? l10n.profileReturnAddressLabel
        : (bound ? l10n.bindChangeTitle : l10n.bindAccountTitle);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              if (bound)
                _ReturnAddressCard(
                  label: l10n.bindChangeCurrentLabel,
                  value: _currentReturnAddress(l10n, user),
                  hint: canBind
                      ? l10n.bindChangeHint
                      : l10n.bindRegisteredReadonlyHint,
                )
              else if (canBind)
                Text(
                  l10n.bindAccountHint,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              if (canBind) ...[
                const SizedBox(height: 20),
                _BindMethodSwitch(
                  method: _method,
                  emailLabel: l10n.bindMethodEmail,
                  googleLabel: l10n.bindMethodGoogle,
                  showGoogle: _showGoogle,
                  onChanged: _busy
                      ? null
                      : (m) => setState(() => _method = m),
                ),
                const SizedBox(height: 20),
                if (_method == _BindMethod.email) ...[
                  PostalTextField(
                    controller: _email,
                    label: l10n.authEmailLabel,
                    hint: l10n.authEmailHint,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.alternate_email,
                    validator: (v) {
                      final s = v?.trim() ?? '';
                      if (s.isEmpty) return l10n.authFieldRequired;
                      if (!s.contains('@') || !s.contains('.')) {
                        return l10n.authEmailInvalid;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  PostalVerifyCodeField(
                    controller: _code,
                    label: l10n.bindCodeLabel,
                    hint: l10n.bindCodeHint,
                    sendLabel: l10n.bindSendCode,
                    sending: _sendingCode,
                    cooldownSeconds: _cooldown,
                    enabled: !_busy,
                    onSend: _sendCode,
                    validator: (v) {
                      final s = v?.trim() ?? '';
                      if (s.isEmpty) {
                        return l10n.settingsEmailVerifyCodeRequired;
                      }
                      if (!RegExp(r'^\d{6}$').hasMatch(s)) {
                        return l10n.authForgotCodeInvalid;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  PostalTextField(
                    controller: _password,
                    label: l10n.authPasswordLabel,
                    hint: '••••••••',
                    prefixIcon: Icons.lock_outline,
                    obscure: true,
                    validator: (v) {
                      if (v == null || v.length < 8) {
                        return l10n.authRegisterWizardPasswordSubtitle;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  PostalButton(
                    label: bound
                        ? l10n.bindAccountSubmitChange
                        : l10n.bindAccountSubmit,
                    variant: PostalButtonVariant.primaryLarge,
                    busy: _busy,
                    onPressed: _busy ? null : _submitEmail,
                  ),
                ] else ...[
                  Text(
                    l10n.bindGoogleHint,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  PostalButton(
                    label: bound
                        ? l10n.bindGoogleSubmitChange
                        : l10n.bindGoogleSubmit,
                    icon: Icons.g_mobiledata_rounded,
                    variant: PostalButtonVariant.primaryLarge,
                    busy: _busy,
                    onPressed: _busy ? null : _submitGoogle,
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

String _currentReturnAddress(AppLocalizations l10n, AppUser user) {
  final email = user.email.trim();
  if (user.bindProvider == 'google') {
    if (email.isEmpty) {
      return l10n.bindMethodGoogle;
    }
    return '${l10n.bindMethodGoogle} · $email';
  }
  if (email.isNotEmpty) {
    return email;
  }
  return l10n.profileBindAccount;
}

/// 信封左上角式回邮地址条：展示当前绑定，提醒更换后怎么登录。
class _ReturnAddressCard extends StatelessWidget {
  const _ReturnAddressCard({
    required this.label,
    required this.value,
    required this.hint,
  });

  final String label;
  final String value;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: PostalTokens.paperEnvelope,
        borderRadius: PostalTokens.shapeMd,
        border: Border.all(color: PostalTokens.kraftBrown, width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(
              color: PostalTokens.kraftBrown,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: PostalTokens.inkNavy,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            hint,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: PostalTokens.inkSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// 邮箱 / Google 二选一切换，大触控区。
class _BindMethodSwitch extends StatelessWidget {
  const _BindMethodSwitch({
    required this.method,
    required this.emailLabel,
    required this.googleLabel,
    required this.showGoogle,
    required this.onChanged,
  });

  final _BindMethod method;
  final String emailLabel;
  final String googleLabel;
  final bool showGoogle;
  final ValueChanged<_BindMethod>? onChanged;

  @override
  Widget build(BuildContext context) {
    if (!showGoogle) {
      return const SizedBox.shrink();
    }
    return Row(
      children: [
        Expanded(
          child: _choice(
            context,
            selected: method == _BindMethod.email,
            icon: Icons.alternate_email,
            label: emailLabel,
            onTap: onChanged == null
                ? null
                : () => onChanged!(_BindMethod.email),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _choice(
            context,
            selected: method == _BindMethod.google,
            icon: Icons.g_mobiledata_rounded,
            label: googleLabel,
            onTap: onChanged == null
                ? null
                : () => onChanged!(_BindMethod.google),
          ),
        ),
      ],
    );
  }

  Widget _choice(
    BuildContext context, {
    required bool selected,
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    final border = selected
        ? PostalTokens.postboxGreen
        : PostalTokens.kraftBrownMuted;
    final fill = selected
        ? PostalTokens.postboxGreen.withValues(alpha: 0.12)
        : PostalTokens.paperEnvelope;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: PostalTokens.shapeMd,
        border: Border.all(color: border, width: selected ? 2 : 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: PostalTokens.shapeMd,
          child: SizedBox(
            height: 56,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: PostalTokens.postboxGreen),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: PostalTokens.inkNavy,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 寄出后可跳过的绑定提示。已绑定或非访客开户则不提示。
/// 返回是否要点「去绑定」；调用方须用 [GoRouter.pushReplacement] 进入绑定页，避免随后 pop 写信页把绑定页一起关掉。
Future<bool> maybePromptBindAfterSend(
  BuildContext context,
  WidgetRef ref,
) async {
  final user = ref.read(appSessionProvider).user;
  if (user.bound || !user.canBind) return false;
  final l10n = AppLocalizations.of(context)!;
  final goBind = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.bindPromptTitle),
      content: Text(l10n.bindPromptBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.bindPromptLater),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l10n.bindPromptNow),
        ),
      ],
    ),
  );
  return goBind == true;
}
