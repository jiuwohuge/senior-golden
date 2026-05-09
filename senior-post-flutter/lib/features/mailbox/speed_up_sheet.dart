import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_exception.dart';
import '../../core/session/app_session.dart';
import '../../widgets/postal/postal.dart';
import '../auth/auth_repository.dart';
import 'mailbox_providers.dart';
import 'mailbox_remote.dart';

class SpeedUpSheet extends ConsumerStatefulWidget {
  const SpeedUpSheet({super.key, required this.letterId});
  final String letterId;

  @override
  ConsumerState<SpeedUpSheet> createState() => _SpeedUpSheetState();
}

class _SpeedUpSheetState extends ConsumerState<SpeedUpSheet> {
  bool _busy = false;

  Future<void> _confirm(BuildContext sheetContext) async {
    setState(() => _busy = true);
    try {
      await ref.read(mailboxRemoteRepositoryProvider).speedUp(widget.letterId);
      if (!sheetContext.mounted) return;
      await ref.read(authRepositoryProvider).refreshSessionFromServer();
      if (!sheetContext.mounted) return;
      ref.invalidate(mailboxLettersProvider);
      ref.invalidate(postalInboxLettersProvider);
      PostalSnack.show(
        sheetContext,
        'Delivery completed',
        tone: PostalSnackTone.success,
      );
      if (sheetContext.mounted) Navigator.of(sheetContext).pop();
    } on ApiBusinessException catch (e) {
      if (sheetContext.mounted) {
        PostalSnack.show(sheetContext, e.message, tone: PostalSnackTone.error);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(appSessionProvider);
    return ScaffoldMessenger(
      child: Builder(
        builder: (sheetContext) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PostalSectionTitle(
                    title: 'Speed Up Delivery',
                    subtitle: session.isVip
                        ? 'VIP: deliver immediately at no stamp cost'
                        : 'Consume 1 stamp to deliver immediately',
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
                    onPressed: _busy ? null : () => _confirm(sheetContext),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
