import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/mock/mock_repository.dart';
import '../../widgets/postal/postal.dart';

class VipCenterPage extends ConsumerWidget {
  const VipCenterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(mockSessionProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('VIP center')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          children: [
            PostalCardEnvelope(
              header: const PostalSectionTitle(
                title: 'VIP Membership',
                subtitle: 'Unlimited stamps and free speed-up',
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PostalStampBadge(
                    isVip: session.isVip,
                    balance: session.stampBalance,
                    cap: session.dailyStampCap,
                  ),
                  const SizedBox(height: 10),
                  const Text('• Unlimited registered mail'),
                  const Text('• Free speed-up for standard post'),
                  const Text('• Priority visibility in directory'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            PostalButton(
              label: session.isVip ? 'Cancel VIP (mock)' : 'Activate VIP (mock)',
              onPressed: () {
                ref.read(mockSessionProvider.notifier).toggleVip();
                PostalSnack.show(
                  context,
                  'Mock: VIP status changed',
                  tone: PostalSnackTone.success,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
