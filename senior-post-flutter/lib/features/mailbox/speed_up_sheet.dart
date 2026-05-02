import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_exception.dart';
import '../../core/mock/mock_repository.dart';
import '../../widgets/postal/postal.dart';
import 'mailbox_providers.dart';

class SpeedUpSheet extends ConsumerStatefulWidget {
  const SpeedUpSheet({super.key, required this.letterId});
  final String letterId;

  @override
  ConsumerState<SpeedUpSheet> createState() => _SpeedUpSheetState();
}

class _SpeedUpSheetState extends ConsumerState<SpeedUpSheet> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(mockSessionProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PostalSectionTitle(
              title: 'Speed Up Delivery',
              subtitle: 'Consume 1 stamp to deliver immediately',
            ),
            const SizedBox(height: 10),
            PostalStampBadge(
              balance: session.stampBalance,
              cap: session.dailyStampCap,
              isVip: session.isVip,
            ),
            const SizedBox(height: 12),
            PostalButton(
              label: 'Confirm speed up',
              busy: _busy,
              onPressed: _busy
                  ? null
                  : () async {
                      setState(() => _busy = true);
                      try {
                        await ref
                            .read(mockMailboxRepositoryProvider)
                            .speedUp(widget.letterId);
                        if (!context.mounted) return;
                        ref.invalidate(mailboxLettersProvider);
                        ref.invalidate(postalInboxLettersProvider);
                        PostalSnack.show(
                          context,
                          'Mock: delivery completed',
                          tone: PostalSnackTone.success,
                        );
                        if (context.mounted) Navigator.of(context).pop();
                      } on ApiBusinessException catch (e) {
                        if (context.mounted) {
                          PostalSnack.show(
                            context,
                            e.message,
                            tone: PostalSnackTone.error,
                          );
                        }
                      } finally {
                        if (context.mounted) setState(() => _busy = false);
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}
