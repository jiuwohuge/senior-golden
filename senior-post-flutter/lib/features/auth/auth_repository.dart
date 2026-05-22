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

class AuthSignInResult {
  const AuthSignInResult({required this.profileComplete});

  final bool profileComplete;
}

class AuthRepository {
  AuthRepository(this._ref);

  final Ref _ref;

  Future<AuthSignInResult> login({
    required String email,
    required String password,
  }) async {
    final dio = _ref.read(dioProvider);
    final deviceUuid = await _ensureDeviceUuid();
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
      return _applyAuthResponse(res);
    } on DioException catch (e) {
      _throwMappedDio(e);
    }
  }

  Future<void> validateRegisterEmail({required String email}) async {
    final dio = _ref.read(dioProvider);
    try {
      await dio.get<Map<String, dynamic>>(
        '/api/auth/register/email-check',
        queryParameters: <String, dynamic>{'email': email.trim()},
      );
    } on DioException catch (e) {
      _throwMappedDio(e);
    }
  }

  Future<AuthSignInResult> signInWithGoogle({required String idToken}) async {
    final dio = _ref.read(dioProvider);
    final deviceUuid = await _ensureDeviceUuid();
    try {
      final res = await dio.post<Map<String, dynamic>>(
        '/api/auth/google',
        data: <String, dynamic>{
          'idToken': idToken,
          'agreedTerms': true,
          'deviceUuid': deviceUuid,
          'deviceType': _deviceTypeBody(),
        },
      );
      return _applyAuthResponse(res);
    } on DioException catch (e) {
      _throwMappedDio(e);
    }
  }

  Future<AuthSignInResult> completeGoogleProfile({
    required int gender,
    required int birthYear,
    required String nickname,
    String? countryCode,
    required List<int> interestTagIds,
    String? avatarUrl,
  }) async {
    if (interestTagIds.length < 3) {
      throw ApiBusinessException(400, 'Please select at least 3 interests.');
    }
    final dio = _ref.read(dioProvider);
    try {
      final res = await dio.post<Map<String, dynamic>>(
        '/api/auth/google/complete',
        data: <String, dynamic>{
          'gender': gender,
          'birthYear': birthYear,
          'nickname': nickname.trim(),
          if (countryCode != null && countryCode.isNotEmpty)
            'countryCode': countryCode.trim(),
          'interestTagIds': interestTagIds,
          if (avatarUrl != null && avatarUrl.isNotEmpty) 'avatarUrl': avatarUrl,
        },
      );
      return _applyAuthResponse(res);
    } on DioException catch (e) {
      _throwMappedDio(e);
    }
  }

  Future<AuthSignInResult> register({
    required String email,
    required String password,
    required String nickname,
    required int gender,
    required int birthYear,
    String? countryCode,
    required bool agreedTerms,
    List<int> interestTagIds = const [],
    String? avatarUrl,
  }) async {
    if (interestTagIds.length < 3) {
      throw ApiBusinessException(400, 'Please select at least 3 interests.');
    }
    final dio = _ref.read(dioProvider);
    final deviceUuid = await _ensureDeviceUuid();
    try {
      final res = await dio.post<Map<String, dynamic>>(
        '/api/auth/register',
        data: <String, dynamic>{
          'email': email.trim(),
          'password': password,
          'nickname': nickname.trim(),
          'gender': gender,
          'birthYear': birthYear,
          if (countryCode != null && countryCode.isNotEmpty)
            'countryCode': countryCode.trim(),
          'agreedTerms': agreedTerms,
          'interestTagIds': interestTagIds,
          if (avatarUrl != null && avatarUrl.isNotEmpty) 'avatarUrl': avatarUrl,
          'deviceUuid': deviceUuid,
          'deviceType': _deviceTypeBody(),
        },
      );
      return _applyAuthResponse(res);
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

  Future<void> requestAccountDeletion() async {
    final dio = _ref.read(dioProvider);
    try {
      await dio.post<Map<String, dynamic>>(
        '/api/auth/account/deletion-request',
      );
    } on DioException catch (e) {
      _throwMappedDio(e);
    }
  }

  Future<void> updateProfileOnServer({
    String? nickname,
    String? countryCode,
    String? bio,
    String? avatarUrl,
    List<int>? interestTagIds,
    int? gender,
  }) async {
    final dio = _ref.read(dioProvider);
    try {
      final body = <String, dynamic>{};
      if (gender != null) body['gender'] = gender;
      if (nickname != null) body['nickname'] = nickname.trim();
      if (countryCode != null) body['countryCode'] = countryCode.trim();
      if (bio != null) body['bio'] = bio.trim();
      if (avatarUrl != null) body['avatarUrl'] = avatarUrl;
      if (interestTagIds != null) body['interestTagIds'] = interestTagIds;
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

  Future<AuthSignInResult> _applyAuthResponse(
    Response<Map<String, dynamic>> res,
  ) async {
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
    final complete = data['profileComplete'] as bool? ?? true;
    return AuthSignInResult(profileComplete: complete);
  }

  Future<String> _ensureDeviceUuid() async {
    String deviceUuid = _ref.read(deviceInstallIdStateProvider);
    if (deviceUuid.isEmpty) {
      deviceUuid = await DeviceInstallId.getOrCreate();
      _ref.read(deviceInstallIdStateProvider.notifier).state = deviceUuid;
    }
    return deviceUuid;
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
