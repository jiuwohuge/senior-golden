import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_exception.dart';
import '../auth/auth_storage.dart';
import '../auth/auth_token.dart';
import '../config/api_base_url.dart';
import '../device/device_ids.dart';
import 'router_refresh.dart';

/// 业务 HTTP 客户端。真机勿依赖默认 127.0.0.1，见 [kApiBaseUrl]。
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: kApiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = ref.read(authTokenProvider);
        if (token != null && token.isNotEmpty) {
          options.headers['Token'] = token;
        }
        options.headers['versionCode'] = '1';
        options.headers['deviceId'] = platformDeviceHeader();
        final equip = ref.read(deviceInstallIdStateProvider);
        if (equip.isNotEmpty) {
          options.headers['equipmentId'] = equip;
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        final data = response.data;
        if (data is String) {
          try {
            response.data = jsonDecode(data) as Object?;
          } catch (_) {
            handler.next(response);
            return;
          }
        }
        if (response.data is Map<String, dynamic>) {
          final map = response.data as Map<String, dynamic>;
          if (map.containsKey('code') && map.containsKey('success')) {
            final code = map['code'] as int? ?? 0;
            final success = map['success'] as bool? ?? false;
            final message = map['message'] as String? ?? '';
            if (code >= 8500 && code <= 8599) {
              _clearAuth(ref);
              handler.reject(
                DioException(
                  requestOptions: response.requestOptions,
                  response: response,
                  type: DioExceptionType.badResponse,
                  error: ApiBusinessException(code, message),
                ),
              );
              return;
            }
            if (!success) {
              handler.reject(
                DioException(
                  requestOptions: response.requestOptions,
                  response: response,
                  type: DioExceptionType.badResponse,
                  error: ApiBusinessException(code, message),
                ),
              );
              return;
            }
          }
        }
        handler.next(response);
      },
    ),
  );

  return dio;
});

void _clearAuth(Ref ref) {
  ref.read(authTokenProvider.notifier).state = null;
  AuthStorage.clearToken();
  ref.read(routerRefreshProvider).value++;
}

/// 从已校验成功的响应中取出 `data`（`onResponse` 已拦截 `success == false` 与 `85xx`）。
T unwrapData<T>(Response<dynamic> response, T Function(Object? raw) parse) {
  final raw = response.data;
  if (raw is! Map<String, dynamic>) {
    throw ApiBusinessException(0, 'Invalid response shape');
  }
  return parse(raw['data']);
}
