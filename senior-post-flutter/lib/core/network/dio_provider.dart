import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/router/app_navigator_key.dart';
import '../../app/router/shop_routes.dart';
import '../../widgets/postal/postal_snack.dart';
import '../api/api_exception.dart';
import '../api/biz_error_codes.dart';
import '../auth/auth_storage.dart';
import '../auth/auth_token.dart';
import '../config/api_base_url.dart';
import '../device/device_ids.dart';
import '../i18n/effective_app_locale_provider.dart';
import '../i18n/locale_resolution.dart';
import 'jh_api_crypto.dart';
import 'router_refresh.dart';

const String _kApiVersionCode = String.fromEnvironment(
  'API_VERSION_CODE',
  defaultValue: '2',
);

/// 是否打印 Dio 请求/响应（默认：debug 模式开启；Release 可加 `--dart-define=API_LOG=true`）。
const bool _kApiVerboseLog = bool.fromEnvironment(
  'API_LOG',
  defaultValue: false,
);

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
        final locale = ref.read(effectiveAppLocaleProvider);
        options.headers['Accept-Language'] = acceptLanguageHeader(locale);
        options.headers['versionCode'] = _kApiVersionCode;
        options.headers['deviceId'] = platformDeviceHeader();
        final equip = ref.read(deviceInstallIdStateProvider);
        if (equip.isNotEmpty) {
          options.headers['equipmentId'] = equip;
        }
        final path = options.uri.path;
        final wrapped = JhApiCrypto.wrapJsonBodyIfNeeded(path, options.data);
        if (wrapped != null) {
          options.data = wrapped;
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
          final path = response.requestOptions.uri.path;
          final dec = JhApiCrypto.tryDecryptResponseDataField(path, map['data']);
          if (dec != null) {
            try {
              map['data'] = jsonDecode(dec) as Object?;
            } catch (_) {
              map['data'] = dec;
            }
          }
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
              if (BizErrorCodes.shouldOpenCommerceHub(code)) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ShopRoutes.pushFromRoot(bizCode: code, message: message);
                });
              } else if (code == BizErrorCodes.defaultBusiness &&
                  message.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final ctx = appRootNavigatorKey.currentContext;
                  if (ctx != null && ctx.mounted) {
                    PostalSnack.show(
                      ctx,
                      message,
                      tone: PostalSnackTone.warning,
                    );
                  }
                });
              }
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

  if (kDebugMode || _kApiVerboseLog) {
    dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        logPrint: (o) => debugPrint('[DIO] $o'),
      ),
    );
  }

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
