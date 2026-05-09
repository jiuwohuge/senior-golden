import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/domain_models.dart';
import 'mailbox_remote.dart';

final mailboxArchiveProvider = FutureProvider<List<MailboxLetter>>((ref) async {
  return ref.read(mailboxRemoteRepositoryProvider).listArchive();
});

final mailboxLettersProvider = FutureProvider<List<MailboxLetter>>((ref) async {
  return ref.read(mailboxRemoteRepositoryProvider).listArchive();
});

final postalInboxLettersProvider = FutureProvider<List<MailboxLetter>>((ref) async {
  return ref.read(mailboxRemoteRepositoryProvider).listPostalInbox();
});

final mailboxFriendsProvider = FutureProvider<List<FriendListRow>>((ref) async {
  return ref.read(mailboxRemoteRepositoryProvider).listMailboxFriends();
});
