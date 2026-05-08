import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_exception.dart';
import '../../core/auth/auth_storage.dart';
import '../../core/auth/auth_token.dart';
import '../../core/device/device_ids.dart';
import '../../core/env/app_env.dart';
import '../../core/mock/mock_delay.dart';
import '../../core/mock/mock_repository.dart';
import '../../core/network/dio_provider.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref);
});

class AuthRepository {
  AuthRepository(this._ref);

  final Ref _ref;

  Future<void> login({required String email, required String password}) async {
    if (AppEnv.useMock) {
      return _mockLogin(email: email, password: password);
    }
    return _realLogin(email: email, password: password);
  }

  Future<void> register({
    required String email,
    required String password,
    required String nickname,
    required int birthYear,
    String? countryCode,
    required bool agreedTerms,
  }) async {
    if (AppEnv.useMock) {
      return _mockRegister(email: email);
    }
    return _realRegister(
      email: email,
      password: password,
      nickname: nickname,
      birthYear: birthYear,
      countryCode: countryCode,
      agreedTerms: agreedTerms,
    );
  }

  Future<void> forgotPassword({required String email}) async {
    if (AppEnv.useMock) {
      await MockDelay.network();
      if (!_isLikelyEmail(email)) {
        throw ApiBusinessException(4002, 'Please enter a valid email address.');
      }
      return;
    }
    final dio = _ref.read(dioProvider);
    try {
      await dio.post<Map<String, dynamic>>(
        '/api/auth/forgot-password',
        data: <String, dynamic>{'email': email.trim()},
      );
    } on DioException catch (e) {
      _throwMappedDio(e);
    }
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    if (AppEnv.useMock) {
      await MockDelay.network();
      if (!RegExp(r'^\d{6}$').hasMatch(code.trim())) {
        throw ApiBusinessException(4003, 'Verification code is incorrect.');
      }
      return;
    }
    final dio = _ref.read(dioProvider);
    try {
      await dio.post<Map<String, dynamic>>(
        '/api/auth/reset-password',
        data: <String, dynamic>{
          'email': email.trim(),
          'code': code.trim(),
          'newPassword': newPassword,
        },
      );
    } on DioException catch (e) {
      _throwMappedDio(e);
    }
  }

  Future<void> logout() async {
    await AuthStorage.clearToken();
    _ref.read(authTokenProvider.notifier).state = null;
  }

  /// 拉取 `/api/auth/me` 并写入 [mockSessionProvider]（非 Mock 下个人中心等展示用）。
  Future<void> refreshSessionFromServer() async {
    if (AppEnv.useMock) return;
    final dio = _ref.read(dioProvider);
    try {
      final res = await dio.get<Map<String, dynamic>>('/api/auth/me');
      final data = unwrapData<Map<String, dynamic>>(res, (raw) {
        return raw! as Map<String, dynamic>;
      });
      _ref.read(mockSessionProvider.notifier).applyFromPublicUserVo(data);
    } on DioException catch (e) {
      _throwMappedDio(e);
    }
  }

  /// `PATCH /api/auth/profile`，成功后刷新本地会话展示态。
  Future<void> updateProfileOnServer({
    required String nickname,
    String? countryCode,
    required String bio,
    String? avatarUrl,
  }) async {
    if (AppEnv.useMock) return;
    final dio = _ref.read(dioProvider);
    try {
      final body = <String, dynamic>{
        'nickname': nickname.trim(),
        'countryCode': countryCode?.trim() ?? '',
        'bio': bio.trim(),
      };
      if (avatarUrl != null) {
        body['avatarUrl'] = avatarUrl;
      }
      final res = await dio.patch<Map<String, dynamic>>(
        '/api/auth/profile',
        data: body,
      );
      final data = unwrapData<Map<String, dynamic>>(res, (raw) {
        return raw! as Map<String, dynamic>;
      });
      _ref.read(mockSessionProvider.notifier).applyFromPublicUserVo(data);
    } on DioException catch (e) {
      _throwMappedDio(e);
    }
  }

  // ──────────────────────────────────────────────
  // Mock 分支
  // ──────────────────────────────────────────────

  Future<void> _mockLogin({
    required String email,
    required String password,
  }) async {
    await MockDelay.network();
    if (!_isLikelyEmail(email)) {
      throw ApiBusinessException(4002, 'Please enter a valid email address.');
    }
    if (password.trim().length < 8) {
      throw ApiBusinessException(4004, 'Password must be at least 8 characters.');
    }
    const mockToken = 'mock.jwt.token.senior-post';
    await AuthStorage.writeToken(mockToken);
    _ref.read(authTokenProvider.notifier).state = mockToken;
  }

  Future<void> _mockRegister({required String email}) async {
    await MockDelay.network();
    if (!_isLikelyEmail(email)) {
      throw ApiBusinessException(4002, 'Please enter a valid email address.');
    }
    const mockToken = 'mock.jwt.token.senior-post';
    await AuthStorage.writeToken(mockToken);
    _ref.read(authTokenProvider.notifier).state = mockToken;
  }

  bool _isLikelyEmail(String value) {
    final v = value.trim();
    if (v.length < 5) return false;
    final at = v.indexOf('@');
    if (at <= 0 || at == v.length - 1) return false;
    return v.contains('.');
  }

  // ──────────────────────────────────────────────
  // 真实接口（保留供后端联调阶段切回）
  // ──────────────────────────────────────────────

  Future<void> _realLogin({
    required String email,
    required String password,
  }) async {
    final dio = _ref.read(dioProvider);
    final deviceUuid = _ref.read(deviceInstallIdStateProvider);
    try {
      final res = await dio.post<Map<String, dynamic>>(
        '/api/auth/login',
        data: <String, dynamic>{
          'email': email.trim(),
          'password': password,
          'deviceUuid': deviceUuid,
          'deviceType': _deviceTypeBody(),
        },
      );
      final data = unwrapData<Map<String, dynamic>>(res, (raw) {
        return raw! as Map<String, dynamic>;
      });
      final token = data['token']! as String;
      await AuthStorage.writeToken(token);
      _ref.read(authTokenProvider.notifier).state = token;
      final userMap = data['user'] as Map<String, dynamic>?;
      if (userMap != null) {
        _ref.read(mockSessionProvider.notifier).applyFromPublicUserVo(userMap);
      }
    } on DioException catch (e) {
      _throwMappedDio(e);
    }
  }

  Future<void> _realRegister({
    required String email,
    required String password,
    required String nickname,
    required int birthYear,
    String? countryCode,
    required bool agreedTerms,
  }) async {
    final dio = _ref.read(dioProvider);
    final deviceUuid = _ref.read(deviceInstallIdStateProvider);
    try {
      final res = await dio.post<Map<String, dynamic>>(
        '/api/auth/register',
        data: <String, dynamic>{
          'email': email.trim(),
          'password': password,
          'nickname': nickname.trim(),
          'birthYear': birthYear,
          if (countryCode != null && countryCode.isNotEmpty)
            'countryCode': countryCode.trim(),
          'agreedTerms': agreedTerms,
          'deviceUuid': deviceUuid,
          'deviceType': _deviceTypeBody(),
        },
      );
      final data = unwrapData<Map<String, dynamic>>(res, (raw) {
        return raw! as Map<String, dynamic>;
      });
      final token = data['token']! as String;
      await AuthStorage.writeToken(token);
      _ref.read(authTokenProvider.notifier).state = token;
      final userMap = data['user'] as Map<String, dynamic>?;
      if (userMap != null) {
        _ref.read(mockSessionProvider.notifier).applyFromPublicUserVo(userMap);
      }
    } on DioException catch (e) {
      _throwMappedDio(e);
    }
  }

  String _deviceTypeBody() {
    final h = platformDeviceHeader().toLowerCase();
    if (h == 'ios') return 'ios';
    if (h == 'android') return 'android';
    return 'android';
  }

  Never _throwMappedDio(DioException e) {
    final err = e.error;
    if (err is ApiBusinessException) throw err;
    throw ApiBusinessException(0, e.message ?? 'Network error');
  }
}
