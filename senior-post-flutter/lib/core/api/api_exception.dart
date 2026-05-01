class ApiBusinessException implements Exception {
  ApiBusinessException(this.code, this.message);

  final int code;
  final String message;

  @override
  String toString() => 'ApiBusinessException($code): $message';
}
