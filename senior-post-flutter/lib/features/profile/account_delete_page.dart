import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/postal/postal.dart';

class AccountDeletePage extends StatelessWidget {
  const AccountDeletePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delete account')),
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
              label: 'Submit deletion request (mock)',
              variant: PostalButtonVariant.danger,
              onPressed: () {
                PostalSnack.show(
                  context,
                  'Mock: deletion request submitted',
                  tone: PostalSnackTone.warning,
                );
                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
