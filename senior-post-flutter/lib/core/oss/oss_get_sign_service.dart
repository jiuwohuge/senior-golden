import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_exception.dart';
import '../network/dio_provider.dart';

final ossGetSignServiceProvider = Provider<OssGetSignService>((ref) {
  return OssGetSignService(ref.read(dioProvider));
});

/// `POST /api/oss/get-sign`：批量换取 GET 预签名 URL。
class OssGetSignService {
  OssGetSignService(this._dio);

  final Dio _dio;

  Future<String?> signedUrlForKey(String objectKey) async {
    final urls = await signedUrlsForKeys([objectKey]);
    return urls[objectKey];
  }

  /// 返回 objectKey → signedUrl（仅包含服务端成功签出的项）。
  Future<Map<String, String>> signedUrlsForKeys(List<String> objectKeys) async {
    if (objectKeys.isEmpty) {
      return {};
    }
    final r = await _dio.post<dynamic>(
      '/api/oss/get-sign',
      data: <String, dynamic>{'objectKeys': objectKeys},
    );
    final raw = r.data;
    if (raw is! Map<String, dynamic>) {
      throw ApiBusinessException(0, 'Invalid response shape');
    }
    final data = raw['data'];
    if (data is! Map<String, dynamic>) {
      throw ApiBusinessException(0, 'Expected object data');
    }
    final items = data['items'];
    if (items is! List<dynamic>) {
      throw ApiBusinessException(0, 'Expected items list');
    }
    final out = <String, String>{};
    for (final it in items) {
      if (it is! Map<String, dynamic>) {
        continue;
      }
      final k = it['objectKey'] as String?;
      final u = it['signedUrl'] as String?;
      if (k != null && u != null && k.isNotEmpty && u.isNotEmpty) {
        out[k] = u;
      }
    }
    return out;
  }
}
