import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../app/theme/postal_tokens.dart';
import '../../widgets/postal/postal.dart';
import '../compose/compose_intent.dart';

/// §2.8 首封信引导：资料完成后强制进入，引导写一封 POST_OFFICE 信。
class FirstLetterGuidePage extends ConsumerWidget {
  const FirstLetterGuidePage({super.key});

  static const path = '/onboarding/first-letter';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: PostalTokens.paperCream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.local_post_office_outlined,
                size: 56,
                color: PostalTokens.postboxGreen,
              ),
              const SizedBox(height: 20),
              Text(
                l10n.firstLetterGuideTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: PostalTokens.inkNavy,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.firstLetterGuideSubtitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.45,
                  color: PostalTokens.inkSecondary,
                ),
              ),
              const SizedBox(height: 28),
              PostalCardEnvelope(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.firstLetterGuideHintTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.firstLetterGuideHintBody,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              PostalButton(
                label: l10n.firstLetterGuideCta,
                icon: Icons.edit_outlined,
                variant: PostalButtonVariant.primaryLarge,
                onPressed: () {
                  // 进入邮局发信；模板提示在 compose 正文步展示。
                  context.push(
                    '/compose',
                    extra: const ComposeIntent(
                      kind: ComposeKind.postOffice,
                      fromFirstLetterGuide: true,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
