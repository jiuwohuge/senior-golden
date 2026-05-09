import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tencent_cloud_chat_sdk/enum/conversation_type.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation.dart';

/// C2C 会话未读条数（key 为对端 userId 字符串），由 TIM 会话回调与主动同步维护。
final imC2cUnreadProvider =
    StateNotifierProvider<ImC2cUnreadNotifier, Map<String, int>>((ref) {
      return ImC2cUnreadNotifier();
    });

class ImC2cUnreadNotifier extends StateNotifier<Map<String, int>> {
  ImC2cUnreadNotifier() : super(const {});

  void mergeConversations(List<V2TimConversation> list) {
    if (list.isEmpty) {
      return;
    }
    final next = Map<String, int>.from(state);
    for (final c in list) {
      if (c.type != ConversationType.V2TIM_C2C) {
        continue;
      }
      final id = c.userID;
      if (id == null || id.isEmpty) {
        continue;
      }
      final u = c.unreadCount ?? 0;
      if (u <= 0) {
        next.remove(id);
      } else {
        next[id] = u;
      }
    }
    state = next;
  }

  void clearPeer(String userId) {
    if (!state.containsKey(userId)) {
      return;
    }
    final next = Map<String, int>.from(state)..remove(userId);
    state = next;
  }

  void clearAll() {
    state = const {};
  }
}

int foldImC2cUnreadTotal(Map<String, int> map) {
  return map.values.fold<int>(0, (a, b) => a + b);
}
