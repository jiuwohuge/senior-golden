import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Google 登录封装；未配置 [serverClientId] 时 [signIn] 返回 null。
class GoogleSignInFacade {
  GoogleSignInFacade._();

  static const String _serverClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');

  static bool get isConfigured => _serverClientId.isNotEmpty;

  static GoogleSignIn? _instance;

  static GoogleSignIn? get _client {
    if (!isConfigured) return null;
    _instance ??= GoogleSignIn(
      scopes: const ['email', 'profile'],
      serverClientId: _serverClientId,
    );
    return _instance;
  }

  /// 返回 idToken；用户取消或失败时返回 null。
  static Future<String?> signIn() async {
    if (kIsWeb) return null;
    final client = _client;
    if (client == null) return null;
    try {
      final account = await client.signIn();
      if (account == null) return null;
      final auth = await account.authentication;
      return auth.idToken;
    } catch (_) {
      return null;
    }
  }
}
