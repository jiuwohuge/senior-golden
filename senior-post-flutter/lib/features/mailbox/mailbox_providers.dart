import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_token.dart';
import '../../core/models/domain_models.dart';
import 'mailbox_remote.dart';

final mailboxArchiveProvider = FutureProvider<List<MailboxLetter>>((ref) async {
  ref.watch(authTokenProvider);
  return ref.read(mailboxRemoteRepositoryProvider).listArchive();
});

final mailboxLettersProvider = FutureProvider<List<MailboxLetter>>((ref) async {
  ref.watch(authTokenProvider);
  return ref.read(mailboxRemoteRepositoryProvider).listArchive();
});

final postalInboxLettersProvider = FutureProvider<List<MailboxLetter>>((
  ref,
) async {
  ref.watch(authTokenProvider);
  return ref.read(mailboxRemoteRepositoryProvider).listPostalInbox();
});

final mailboxReceivedProvider = FutureProvider<List<MailboxLetter>>((
  ref,
) async {
  ref.watch(authTokenProvider);
  return ref.read(mailboxRemoteRepositoryProvider).listReceived();
});

final mailboxSentProvider = FutureProvider<List<MailboxLetter>>((ref) async {
  ref.watch(authTokenProvider);
  return ref.read(mailboxRemoteRepositoryProvider).listSent();
});

final mailboxFriendsProvider = FutureProvider<List<FriendListRow>>((ref) async {
  ref.watch(authTokenProvider);
  return ref.read(mailboxRemoteRepositoryProvider).listMailboxFriends();
});

/// 信件详情；[autoDispose] 避免列表已刷新后仍命中旧缓存。
final letterDetailProvider = FutureProvider.autoDispose
    .family<MailboxLetter?, String>((ref, id) async {
      ref.watch(authTokenProvider);
      return ref.read(mailboxRemoteRepositoryProvider).getLetter(id);
    });
