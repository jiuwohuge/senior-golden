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
            PostalCardEnvelope(
              header: PostalSectionTitle(
                title: l10n.accountDeleteSectionTitle,
                subtitle: l10n.accountDeleteCoolingOff,
              ),
              child: Text(l10n.accountDeleteBody),
            ),
            const SizedBox(height: 14),
            PostalButton(
              label: l10n.accountDeleteSubmit,
              variant: PostalButtonVariant.danger,
              onPressed: () async {
                try {
                  await ref
                      .read(authRepositoryProvider)
                      .requestAccountDeletion();
                  if (!context.mounted) return;
                  PostalSnack.show(
                    context,
                    l10n.accountDeleteSubmitted,
                    tone: PostalSnackTone.warning,
                  );
                  await ref
                      .read(authRepositoryProvider)
                      .logout(reenterAsGuest: false);
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
