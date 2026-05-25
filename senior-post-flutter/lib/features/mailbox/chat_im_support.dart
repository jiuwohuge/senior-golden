import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tencent_cloud_chat_sdk/enum/message_priority_enum.dart';
import 'package:tencent_cloud_chat_sdk/manager/v2_tim_manager.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';

import 'im_user_id.dart';
import 'mailbox_remote.dart';
import 'tim_facade.dart';

/// 拉取 C2C 历史：优先读 TIM SDK 本地库；仅在 UserSig 或对端 ID 异常时补偿重试。
///
/// WHY: 腾讯 IM SDK 会持久化消息，`getC2CHistoryMessageList` 先走本地缓存，
/// 无需应用层再建 SQLite；仅在 SDK 报错时才 sync 对端或刷新 UserSig。
Future<V2TimValueCallback<List<V2TimMessage>>> loadC2cHistoryWithRecovery({
  required WidgetRef ref,
  required String peerUserId,
  int count = 30,
}) async {
  final facade = ref.read(seniorPostTimFacadeProvider);
  final repo = ref.read(mailboxRemoteRepositoryProvider);
  await facade.ensureLoggedIn();

  final tim = V2TIMManager();
  var result = await tim.v2TIMMessageManager.getC2CHistoryMessageList(
    userID: peerUserId,
    count: count,
    lastMsg: null,
  );

  if (result.code != 0 && isTimCredentialError(result.code, result.desc)) {
    facade.invalidateCredentials();
    await facade.ensureLoggedIn(forceRefresh: true);
    result = await tim.v2TIMMessageManager.getC2CHistoryMessageList(
      userID: peerUserId,
      count: count,
      lastMsg: null,
    );
  }

  if (result.code != 0 && isImUserIdError(result.desc)) {
    await repo.syncImPeer(peerUserId);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    result = await tim.v2TIMMessageManager.getC2CHistoryMessageList(
      userID: peerUserId,
      count: count,
      lastMsg: null,
    );
  }

  return result;
}

/// 发送消息失败时：先刷新 UserSig，再按需 sync 对端 IM 好友。
Future<V2TimValueCallback<V2TimMessage>> sendC2cTextWithRecovery({
  required WidgetRef ref,
  required String peerUserId,
  required V2TimMessage message,
}) async {
  final facade = ref.read(seniorPostTimFacadeProvider);
  final repo = ref.read(mailboxRemoteRepositoryProvider);
  final tim = V2TIMManager();

  await facade.ensureLoggedIn();
  var send = await tim.v2TIMMessageManager.sendMessage(
    message: message,
    receiver: peerUserId,
    groupID: '',
    priority: MessagePriorityEnum.V2TIM_PRIORITY_NORMAL,
  );

  if (send.code != 0 && isTimCredentialError(send.code, send.desc)) {
    facade.invalidateCredentials();
    await facade.ensureLoggedIn(forceRefresh: true);
    send = await tim.v2TIMMessageManager.sendMessage(
      message: message,
      receiver: peerUserId,
      groupID: '',
      priority: MessagePriorityEnum.V2TIM_PRIORITY_NORMAL,
    );
  }

  if (send.code != 0 && isImUserIdError(send.desc)) {
    await repo.syncImPeer(peerUserId);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    send = await tim.v2TIMMessageManager.sendMessage(
      message: message,
      receiver: peerUserId,
      groupID: '',
      priority: MessagePriorityEnum.V2TIM_PRIORITY_NORMAL,
    );
  }

  return send;
}
