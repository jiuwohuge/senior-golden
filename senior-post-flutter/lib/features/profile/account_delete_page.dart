import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_exception.dart';
import '../auth/auth_repository.dart';
import '../auth/login_routes.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/postal/postal.dart';

class AccountDeletePage extends ConsumerWidget {
  const AccountDeletePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountDeleteTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          children: [
            const PostalCardEnvelope(
              header: PostalSectionTitle(
                title: 'GDPR deletion flow',
                subtitle: '7-day cooling-off period',
              ),
              child: Text(
                'After submission, your account enters a 7-day cooling-off period.\n\n'
                'During this period, you can revoke deletion by logging in again.\n\n'
                'After the cooling-off period, account data and associated content '
                'will be deleted according to policy.',
              ),
            ),
            const SizedBox(height: 14),
            PostalButton(
              label: 'Submit deletion request',
              variant: PostalButtonVariant.danger,
              onPressed: () async {
                try {
                  await ref.read(authRepositoryProvider).requestAccountDeletion();
                  if (!context.mounted) return;
                  PostalSnack.show(
                    context,
                    'Deletion request submitted. You can log in again within 7 days to cancel.',
                    tone: PostalSnackTone.warning,
                  );
                  await ref.read(authRepositoryProvider).logout();
                  if (context.mounted) {
                    context.go(LoginRoutes.login);
                  }
                } on ApiBusinessException catch (e) {
                  if (context.mounted) {
                    PostalSnack.show(
                      context,
                      e.message,
                      tone: PostalSnackTone.error,
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
