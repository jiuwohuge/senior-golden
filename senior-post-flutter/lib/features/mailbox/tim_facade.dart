import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tencent_cloud_chat_sdk/enum/log_level_enum.dart';
import 'package:tencent_cloud_chat_sdk/manager/v2_tim_manager.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation.dart';

import '../../core/api/api_exception.dart';
import '../../core/auth/auth_token.dart';
import '../../core/env/app_env.dart';
import '../../core/network/dio_provider.dart';

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

  Future<void> disposeAsync() async {
    if (AppEnv.useMock) return;
    try {
      await _tim.logout();
    } catch (_) {}
    _sdkInited = false;
    _initSdkAppId = null;
    _loggedUserId = null;
  }

  Future<void> ensureLoggedIn() async {
    if (AppEnv.useMock) return;
    final token = _ref.read(authTokenProvider);
    if (token == null || token.isEmpty) {
      throw ApiBusinessException(8500, 'Not logged in');
    }
    final dio = _ref.read(dioProvider);
    final res = await dio.get<Map<String, dynamic>>('/api/im/usersig');
    final map = unwrapData<Map<String, dynamic>>(res, (raw) {
      return Map<String, dynamic>.from(raw! as Map);
    });
    final sdk = (map['sdkAppId'] as num).toInt();
    final userId = map['userId'] as String? ?? '';
    final sig = map['userSig'] as String? ?? '';
    if (userId.isEmpty || sig.isEmpty) {
      throw ApiBusinessException(400, 'Invalid UserSig response');
    }
    // UserSig 与 initSDK 的 sdkAppID 必须一致；配置变更后需重新 init。
    if (_sdkInited && _initSdkAppId != null && _initSdkAppId != sdk) {
      await _tim.unInitSDK();
      _sdkInited = false;
      _loggedUserId = null;
    }
    if (!_sdkInited) {
      final init = await _tim.initSDK(
        sdkAppID: sdk,
        loglevel: LogLevelEnum.V2TIM_LOG_WARN,
        showImLog: false,
      );
      if (init.code != 0) {
        throw ApiBusinessException(init.code, init.desc);
      }
      _sdkInited = true;
      _initSdkAppId = sdk;
    }
    if (_loggedUserId == userId) {
      return;
    }
    await _tim.logout();
    final login = await _tim.login(userID: userId, userSig: sig);
    if (login.code != 0) {
      throw ApiBusinessException(login.code, login.desc);
    }
    _loggedUserId = userId;
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
