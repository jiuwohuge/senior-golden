import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_storage.dart';
import '../../core/auth/auth_token.dart';
import '../../core/device/device_ids.dart';
import '../../core/api/api_exception.dart';
import '../../core/network/dio_provider.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref);
});

class AuthRepository {
  AuthRepository(this._ref);

  final Ref _ref;

  Future<void> login({required String email, required String password}) async {
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
    } on DioException catch (e) {
      _throwMappedDio(e);
    }
  }

  Future<void> logout() async {
    await AuthStorage.clearToken();
    _ref.read(authTokenProvider.notifier).state = null;
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
