import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_exception.dart';
import '../../core/auth/auth_data_refresh.dart';
import '../../core/auth/auth_storage.dart';
import '../../core/auth/auth_token.dart';
import '../../core/device/device_ids.dart';
import '../../core/device/device_install_id.dart';
import '../../core/network/dio_provider.dart';
import '../../core/session/app_session.dart';
import '../mailbox/tim_facade.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref);
});

class AuthRepository {
  AuthRepository(this._ref);

  final Ref _ref;

  Future<void> login({required String email, required String password}) async {
    final dio = _ref.read(dioProvider);
    String deviceUuid = _ref.read(deviceInstallIdStateProvider);
    if (deviceUuid.isEmpty) {
      deviceUuid = await DeviceInstallId.getOrCreate();
      _ref.read(deviceInstallIdStateProvider.notifier).state = deviceUuid;
    }
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
      _ref.invalidate(seniorPostTimFacadeProvider);
      final userMap = data['user'] as Map<String, dynamic>?;
      if (userMap != null) {
        _ref.read(appSessionProvider.notifier).applyFromPublicUserVo(userMap);
      }
      _ref.read(invalidateAuthDataProvider)();
    } on DioException catch (e) {
      _throwMappedDio(e);
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String nickname,
    required int birthYear,
    String? countryCode,
    required bool agreedTerms,
    List<int> interestTagIds = const [],
  }) async {
    if (interestTagIds.length < 3) {
      throw ApiBusinessException(400, 'Please select at least 3 interests.');
    }
    final dio = _ref.read(dioProvider);
    String deviceUuid = _ref.read(deviceInstallIdStateProvider);
    if (deviceUuid.isEmpty) {
      deviceUuid = await DeviceInstallId.getOrCreate();
      _ref.read(deviceInstallIdStateProvider.notifier).state = deviceUuid;
    }
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
          'interestTagIds': interestTagIds,
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
      _ref.invalidate(seniorPostTimFacadeProvider);
      final userMap = data['user'] as Map<String, dynamic>?;
      if (userMap != null) {
        _ref.read(appSessionProvider.notifier).applyFromPublicUserVo(userMap);
      }
      _ref.read(invalidateAuthDataProvider)();
    } on DioException catch (e) {
      _throwMappedDio(e);
    }
  }

  Future<void> forgotPassword({required String email}) async {
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
    _ref.read(appSessionProvider.notifier).clear();
    _ref.invalidate(seniorPostTimFacadeProvider);
  }

  /// 拉取 `/api/auth/me` 并写入 [appSessionProvider]。
  Future<void> refreshSessionFromServer() async {
    final dio = _ref.read(dioProvider);
    try {
      final res = await dio.get<Map<String, dynamic>>('/api/auth/me');
      final data = unwrapData<Map<String, dynamic>>(res, (raw) {
        return raw! as Map<String, dynamic>;
      });
      _ref.read(appSessionProvider.notifier).applyFromPublicUserVo(data);
    } on DioException catch (e) {
      _throwMappedDio(e);
    }
  }

  /// 提交账号注销申请（7 日冷静期；期间再次登录将撤销）。
  Future<void> requestAccountDeletion() async {
    final dio = _ref.read(dioProvider);
    try {
      await dio.post<Map<String, dynamic>>('/api/auth/account/deletion-request');
    } on DioException catch (e) {
      _throwMappedDio(e);
    }
  }

  /// `PATCH /api/auth/profile`，成功后刷新本地会话展示态。
  Future<void> updateProfileOnServer({
    String? nickname,
    String? countryCode,
    String? bio,
    String? avatarUrl,
    List<int>? interestTagIds,
  }) async {
    final dio = _ref.read(dioProvider);
    try {
      final body = <String, dynamic>{};
      if (nickname != null) {
        body['nickname'] = nickname.trim();
      }
      if (countryCode != null) {
        body['countryCode'] = countryCode.trim();
      }
      if (bio != null) {
        body['bio'] = bio.trim();
      }
      if (avatarUrl != null) {
        body['avatarUrl'] = avatarUrl;
      }
      if (interestTagIds != null) {
        body['interestTagIds'] = interestTagIds;
      }
      if (body.isEmpty) {
        throw StateError('updateProfileOnServer: at least one field required');
      }
      final res = await dio.patch<Map<String, dynamic>>(
        '/api/auth/profile',
        data: body,
      );
      final data = unwrapData<Map<String, dynamic>>(res, (raw) {
        return raw! as Map<String, dynamic>;
      });
      _ref.read(appSessionProvider.notifier).applyFromPublicUserVo(data);
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
