import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_repository.dart';
import 'time_letter_remote.dart';

final timeLetterStatsProvider = FutureProvider<TimeLetterStats>((ref) async {
  return ref.read(timeLetterRemoteProvider).stats();
});

final timeLetterAllProvider =
    FutureProvider.autoDispose<List<TimeLetterItem>>((ref) async {
      final remote = ref.read(timeLetterRemoteProvider);
      final outbox = await remote.listOutbox();
      final inbox = await remote.listInbox();
      final memorial = await remote.listMemorial();
      final byId = <String, TimeLetterItem>{};
      for (final item in [...outbox, ...inbox, ...memorial]) {
        byId[item.id] = item;
      }
      final list = byId.values.toList();
      list.sort((a, b) {
        final ak = a.sealedAt ?? a.deliveryDate ?? '';
        final bk = b.sealedAt ?? b.deliveryDate ?? '';
        return bk.compareTo(ak);
      });
      return list;
    });

final timeLetterRecentRecipientsProvider =
    FutureProvider.autoDispose<List<TimeLetterRecentRecipient>>((ref) async {
      return ref.read(timeLetterRemoteProvider).recentRecipients();
    });

final timeLetterDetailProvider = FutureProvider.autoDispose
    .family<TimeLetterDetail, String>((ref, id) async {
      return ref.read(timeLetterRemoteProvider).getDetail(id);
    });

void invalidateTimeLetterLists(WidgetRef ref) {
  ref.invalidate(timeLetterStatsProvider);
  ref.invalidate(timeLetterAllProvider);
}

Future<void> refreshSessionStampsAfterSeal(
  WidgetRef ref,
  int? balanceAfter,
) async {
  if (balanceAfter != null) {
    await ref.read(authRepositoryProvider).refreshSessionFromServer();
  } else {
    await ref.read(authRepositoryProvider).refreshSessionFromServer();
  }
}
