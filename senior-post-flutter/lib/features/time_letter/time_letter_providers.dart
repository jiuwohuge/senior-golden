import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_repository.dart';
import 'time_letter_remote.dart';

final timeLetterStatsProvider = FutureProvider<TimeLetterStats>((ref) async {
  return ref.read(timeLetterRemoteProvider).stats();
});

final timeLetterOutboxProvider =
    FutureProvider.autoDispose<List<TimeLetterItem>>((ref) async {
      return ref.read(timeLetterRemoteProvider).listOutbox();
    });

final timeLetterInboxProvider =
    FutureProvider.autoDispose<List<TimeLetterItem>>((ref) async {
      return ref.read(timeLetterRemoteProvider).listInbox();
    });

final timeLetterMemorialProvider =
    FutureProvider.autoDispose<List<TimeLetterItem>>((ref) async {
      return ref.read(timeLetterRemoteProvider).listMemorial();
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
  ref.invalidate(timeLetterOutboxProvider);
  ref.invalidate(timeLetterInboxProvider);
  ref.invalidate(timeLetterMemorialProvider);
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
