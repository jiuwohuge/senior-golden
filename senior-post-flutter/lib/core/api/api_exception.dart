import 'package:dio/dio.dart';

class ApiBusinessException implements Exception {
  ApiBusinessException(this.code, this.message);

  final int code;
  final String message;

  @override
  String toString() => 'ApiBusinessException($code): $message';
}

/// Dio 拦截器把业务错误挂在 [DioException.error] 上，调用方需统一解包。
ApiBusinessException? apiBusinessExceptionFrom(Object? error) {
  if (error is ApiBusinessException) {
    return error;
  }
  if (error is DioException && error.error is ApiBusinessException) {
    return error.error as ApiBusinessException;
  }
  return null;
}
