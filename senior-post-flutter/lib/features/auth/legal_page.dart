import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../widgets/postal/postal.dart';
import 'login_routes.dart';

enum LegalPageType { terms, privacy }

class LegalPage extends StatelessWidget {
  const LegalPage({super.key, required this.type});

  final LegalPageType type;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isTerms = type == LegalPageType.terms;
    final title = isTerms ? l10n.authTermsTitle : l10n.authPrivacyTitle;
    final content = isTerms ? l10n.legalTermsContent : l10n.legalPrivacyContent;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          PostalButton(
            label: l10n.authBackToLogin,
            onPressed: () => context.go(LoginRoutes.login),
            variant: PostalButtonVariant.ghost,
            expand: false,
            minHeight: 38,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: PaperTextureBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            children: [
              PostalCardEnvelope(
                header: PostalSectionTitle(
                  title: title,
                  subtitle: l10n.legalEffectiveDate,
                ),
                child: Text(
                  content,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.65),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
