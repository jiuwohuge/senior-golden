import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation.dart';

import '../../core/env/app_env.dart';
import '../../core/mock/mock_models.dart';
import '../../core/mock/mock_repository.dart';
import 'mailbox_remote.dart';
import 'tim_facade.dart';

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

/// Mock 下 Connections 数据源；非 Mock 走 [timConversationsProvider]。
final mockConnectionsProvider = FutureProvider<List<MockImConnectionRow>>((
  ref,
) async {
  return ref.read(mockMailboxRepositoryProvider).listMockConnections();
});

/// 腾讯 IM 会话第一页（需后端签发 UserSig 且控制台已配置）。
final timConversationsProvider = FutureProvider<List<V2TimConversation>>((
  ref,
) async {
  if (AppEnv.useMock) {
    return const [];
  }
  final facade = ref.read(seniorPostTimFacadeProvider);
  await facade.ensureLoggedIn();
  return facade.conversationFirstPage();
});
