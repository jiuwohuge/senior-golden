import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/bootstrap/app_bootstrap.dart';
import '../../widgets/postal/postal.dart';
import 'login_routes.dart';

enum LegalPageType { terms, privacy }

class LegalPage extends ConsumerStatefulWidget {
  const LegalPage({super.key, required this.type});

  final LegalPageType type;

  @override
  ConsumerState<LegalPage> createState() => _LegalPageState();
}

class _LegalPageState extends ConsumerState<LegalPage> {
  String? _attemptedUrl;
  bool _opening = false;
  bool _openFailed = false;

  Uri? _safeUri(String raw) {
    final uri = Uri.tryParse(raw.trim());
    if (uri == null || !uri.hasAuthority) return null;
    if (uri.scheme != 'https' && uri.scheme != 'http') return null;
    return uri;
  }

  Future<void> _open(Uri uri) async {
    if (_opening) return;
    setState(() {
      _opening = true;
      _openFailed = false;
      _attemptedUrl = uri.toString();
    });
    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_self',
      );
      if (mounted && !opened) {
        setState(() => _openFailed = true);
      }
    } catch (_) {
      if (mounted) setState(() => _openFailed = true);
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(LoginRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isTerms = widget.type == LegalPageType.terms;
    final title = isTerms ? l10n.authTermsTitle : l10n.authPrivacyTitle;
    final lang = Localizations.localeOf(context).languageCode;
    final bootstrap = ref.watch(appBootstrapProvider(lang));

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => _goBack(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: PaperTextureBackground(
        child: SafeArea(
          child: bootstrap.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => PostalEmptyState(
              title: title,
              subtitle: l10n.commonLoadFailedHint,
              tone: PostalEmptyTone.error,
              actionLabel: l10n.authRetry,
              onAction: () => ref.invalidate(appBootstrapProvider(lang)),
            ),
            data: (data) {
              final raw = isTerms ? data.termsUrl : data.privacyUrl;
              final uri = _safeUri(raw);
              if (uri == null) {
                return PostalEmptyState(
                  title: title,
                  subtitle: l10n.legalUrlNotConfigured,
                  tone: PostalEmptyTone.error,
                );
              }
              if (_attemptedUrl != uri.toString() && !_opening) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _open(uri);
                });
              }
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: PostalCardEnvelope(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.open_in_browser_outlined, size: 42),
                        const SizedBox(height: 16),
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        if (_openFailed) ...[
                          const SizedBox(height: 10),
                          Text(
                            l10n.legalOpenFailed,
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 20),
                        PostalButton(
                          label: l10n.legalOpenDocument,
                          icon: Icons.open_in_new,
                          onPressed: _opening ? null : () => _open(uri),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
