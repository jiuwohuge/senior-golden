/// 与后端统一响应 `ApiResponse` 对齐（commons-web 包装）。
class ApiEnvelope<T> {
  ApiEnvelope({
    required this.code,
    required this.message,
    required this.success,
    this.data,
  });

  final int code;
  final String message;
  final bool success;
  final T? data;

  static ApiEnvelope<Map<String, dynamic>> fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return ApiEnvelope<Map<String, dynamic>>(
      code: json['code'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      success: json['success'] as bool? ?? false,
      data: data is Map<String, dynamic> ? data : null,
    );
  }

  static ApiEnvelope<List<dynamic>> fromJsonList(Map<String, dynamic> json) {
    final data = json['data'];
    return ApiEnvelope<List<dynamic>>(
      code: json['code'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      success: json['success'] as bool? ?? false,
      data: data is List<dynamic> ? data : null,
    );
  }

  bool get isTokenBusinessError => code >= 8500 && code <= 8599;
}
