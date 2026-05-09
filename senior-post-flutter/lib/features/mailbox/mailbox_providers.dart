import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/env/app_env.dart';
import '../../core/mock/mock_models.dart';
import '../../core/mock/mock_repository.dart';
import 'mailbox_remote.dart';

/// 信件归档列表。
final mailboxArchiveProvider = FutureProvider<List<MockLetter>>((ref) async {
  if (AppEnv.useMock) {
    return ref.read(mockMailboxRepositoryProvider).listArchive();
  }
  return ref.read(mailboxRemoteRepositoryProvider).listArchive();
});

/// 全量信件（详情、加速、归档数据源）。非 Mock 时与归档接口一致。
final mailboxLettersProvider = FutureProvider<List<MockLetter>>((ref) async {
  if (AppEnv.useMock) {
    return ref.read(mockMailboxRepositoryProvider).list();
  }
  return ref.read(mailboxRemoteRepositoryProvider).listArchive();
});

/// Tab「Postal」：未与对端建联的信件。
final postalInboxLettersProvider = FutureProvider<List<MockLetter>>((
  ref,
) async {
  if (AppEnv.useMock) {
    return ref.read(mockMailboxRepositoryProvider).listPostalInbox();
  }
  return ref.read(mailboxRemoteRepositoryProvider).listPostalInbox();
});

/// 邮政 Tab「Connections」：**好友（笔友）列表**，数据来源 `bu_friendship` / `GET /api/mailbox/friends`，
/// **不是** TIM `getConversationList` 会话列表。点击进入聊天仍走 TIM C2C。
final mailboxFriendsProvider = FutureProvider<List<MockImConnectionRow>>((
  ref,
) async {
  if (AppEnv.useMock) {
    return ref.read(mockMailboxRepositoryProvider).listMockConnections();
  }
  return ref.read(mailboxRemoteRepositoryProvider).listMailboxFriends();
});
