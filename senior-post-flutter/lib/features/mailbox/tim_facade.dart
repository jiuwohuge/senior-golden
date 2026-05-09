import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimConversationListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/log_level_enum.dart';
import 'package:tencent_cloud_chat_sdk/manager/v2_tim_manager.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation.dart';

import '../../core/api/api_exception.dart';
import '../../core/auth/auth_token.dart';
import '../../core/network/dio_provider.dart';
import 'im_unread_providers.dart';

final seniorPostTimFacadeProvider = Provider<SeniorPostTimFacade>((ref) {
  final facade = SeniorPostTimFacade(ref);
  ref.onDispose(() {
    facade.disposeAsync();
  });
  return facade;
});

/// 封装 TIM SDK 初始化、登录与会话拉取（UserSig 来自 `/api/im/usersig`）。
class SeniorPostTimFacade {
  SeniorPostTimFacade(this._ref);

  final Ref _ref;
  final V2TIMManager _tim = V2TIMManager();
  bool _sdkInited = false;
  int? _initSdkAppId;
  String? _loggedUserId;

  /// 认为 UserSig 仍可用的截止时间（较服务端 TTL 提前刷新，避免临界过期）。
  DateTime? _credentialUsableUntil;
  V2TimConversationListener? _conversationListener;

  Future<void> disposeAsync() async {
    final l = _conversationListener;
    _conversationListener = null;
    if (l != null) {
      try {
        await _tim.v2TIMConversationManager.removeConversationListener(
          listener: l,
        );
      } catch (_) {}
    }
    try {
      _ref.read(imC2cUnreadProvider.notifier).clearAll();
    } catch (_) {}
    try {
      await _tim.logout();
    } catch (_) {}
    _sdkInited = false;
    _initSdkAppId = null;
    _loggedUserId = null;
    _credentialUsableUntil = null;
  }

  static DateTime? _readUsableUntil(Map<String, dynamic> map) {
    final sec =
        (map['expireInSeconds'] as num?)?.toInt() ??
        (map['expire_in_seconds'] as num?)?.toInt();
    if (sec == null) return null;
    final skew = sec > 600 ? 120 : (sec ~/ 4).clamp(30, 120);
    return DateTime.now().add(Duration(seconds: sec - skew));
  }

  Future<void> _ensureConversationUnreadListener() async {
    if (_conversationListener != null) {
      return;
    }
    final listener = V2TimConversationListener(
      onNewConversation: (list) {
        _ref.read(imC2cUnreadProvider.notifier).mergeConversations(list);
      },
      onConversationChanged: (list) {
        _ref.read(imC2cUnreadProvider.notifier).mergeConversations(list);
      },
    );
    _conversationListener = listener;
    await _tim.v2TIMConversationManager.addConversationListener(
      listener: listener,
    );
    await _syncAllConversationsUnread();
  }

  Future<void> _syncAllConversationsUnread() async {
    var seq = '0';
    for (var i = 0; i < 60; i++) {
      final r = await _tim.v2TIMConversationManager.getConversationList(
        nextSeq: seq,
        count: 100,
      );
      if (r.code != 0) {
        break;
      }
      final data = r.data;
      final list = data?.conversationList;
      if (list != null && list.isNotEmpty) {
        _ref.read(imC2cUnreadProvider.notifier).mergeConversations(list);
      }
      final finished = data?.isFinished == true;
      final next = data?.nextSeq;
      if (finished || next == null || next.isEmpty) {
        break;
      }
      seq = next;
    }
  }

  /// 邮箱页回到前台等时机：在已登录 TIM 时拉取本地会话未读快照。
  Future<void> refreshC2cUnreadIfLoggedIn() async {
    if (!_sdkInited || _loggedUserId == null) {
      return;
    }
    final me = await _tim.getLoginUser();
    if (me.code != 0 || me.data == null || me.data!.isEmpty) {
      return;
    }
    await _syncAllConversationsUnread();
  }

  Future<void> ensureLoggedIn() async {
    final token = _ref.read(authTokenProvider);
    if (token == null || token.isEmpty) {
      throw ApiBusinessException(8500, 'Not logged in');
    }
    final dio = _ref.read(dioProvider);
    try {
      final now = DateTime.now();
      if (_sdkInited &&
          _loggedUserId != null &&
          _credentialUsableUntil != null &&
          now.isBefore(_credentialUsableUntil!)) {
        final me = await _tim.getLoginUser();
        if (me.code == 0 &&
            (me.data != null && me.data!.isNotEmpty) &&
            me.data == _loggedUserId) {
          await _ensureConversationUnreadListener();
          return;
        }
      }

      final res = await dio.get<Map<String, dynamic>>('/api/im/usersig');
      final map = unwrapData<Map<String, dynamic>>(res, (raw) {
        return Map<String, dynamic>.from(raw! as Map);
      });
      final sdk = (map['sdkAppId'] as num).toInt();
      final userId = map['userId'] as String? ?? '';
      final sig = map['userSig'] as String? ?? '';
      if (userId.isEmpty || sig.isEmpty) {
        throw ApiBusinessException(
          400,
          'IM UserSig missing: check server Tencent IM config',
        );
      }
      _credentialUsableUntil = _readUsableUntil(map);
      // UserSig 与 initSDK 的 sdkAppID 必须一致；配置变更后需重新 init。
      if (_sdkInited && _initSdkAppId != null && _initSdkAppId != sdk) {
        await _tim.unInitSDK();
        _sdkInited = false;
        _loggedUserId = null;
        _credentialUsableUntil = null;
      }
      if (!_sdkInited) {
        final init = await _tim.initSDK(
          sdkAppID: sdk,
          loglevel: LogLevelEnum.V2TIM_LOG_WARN,
          showImLog: false,
        );
        if (init.code != 0) {
          throw ApiBusinessException(
            init.code,
            'TIM init failed: ${init.desc}',
          );
        }
        _sdkInited = true;
        _initSdkAppId = sdk;
      }
      try {
        await _tim.logout();
      } catch (_) {}
      final login = await _tim.login(userID: userId, userSig: sig);
      if (login.code != 0) {
        _credentialUsableUntil = null;
        throw ApiBusinessException(
          login.code,
          'TIM login failed: ${login.desc}',
        );
      }
      _loggedUserId = userId;
      await _ensureConversationUnreadListener();
    } on DioException catch (e) {
      throw ApiBusinessException(
        0,
        'Cannot reach IM signing API: ${e.message ?? 'network error'}',
      );
    }
  }

  Future<List<V2TimConversation>> conversationFirstPage() async {
    final r = await _tim.v2TIMConversationManager.getConversationList(
      nextSeq: '0',
      count: 40,
    );
    if (r.code != 0) {
      throw ApiBusinessException(r.code, r.desc);
    }
    return r.data?.conversationList ?? const [];
  }
}
