import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_exception.dart';
import '../network/dio_provider.dart';
import 'oss_put_sign.dart';

final ossUploadServiceProvider = Provider<OssUploadService>((ref) {
  return OssUploadService(ref.read(dioProvider));
});

/// 拉取预签名 URL 并向 OSS 直传字节（不经过业务后端代理）。
class OssUploadService {
  OssUploadService(this._authDio);

  final Dio _authDio;

  Future<OssPutSignResult> fetchPutSign({
    required String scene,
    required String ext,
    String? contentType,
  }) async {
    final res = await _authDio.get<dynamic>(
      '/api/oss/put-sign',
      queryParameters: <String, dynamic>{
        'scene': scene,
        'ext': ext,
        if (contentType != null && contentType.isNotEmpty) 'contentType': contentType,
      },
    );
    final raw = res.data;
    if (raw is! Map<String, dynamic>) {
      throw ApiBusinessException(0, 'Invalid response shape');
    }
    final data = raw['data'];
    if (data is! Map<String, dynamic>) {
      throw ApiBusinessException(0, 'Expected object data');
    }
    return OssPutSignResult.fromJson(data);
  }

  /// PUT 到预签名 URL；成功后可读 URL 优先 [OssPutSignResult.readUrl]。
  Future<String> uploadBytes({
    required OssPutSignResult sign,
    required Uint8List bytes,
  }) async {
    final putClient = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        validateStatus: (s) => s != null && s < 500,
      ),
    );
    try {
      final resp = await putClient.put<dynamic>(
        sign.putUrl,
        data: bytes,
        options: Options(
          headers: <String, dynamic>{'Content-Type': sign.contentType},
        ),
      );
      if (resp.statusCode == null || resp.statusCode! < 200 || resp.statusCode! >= 300) {
        throw ApiBusinessException(
          resp.statusCode ?? 0,
          'OSS upload failed: HTTP ${resp.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw ApiBusinessException(
        0,
        e.message ?? 'OSS upload failed',
      );
    }
    if (sign.readUrl != null && sign.readUrl!.isNotEmpty) {
      return sign.readUrl!;
    }
    throw ApiBusinessException(
      0,
      'Upload OK but no readUrl; set ALIYUN_OSS_PUBLIC_BASE_URL on server',
    );
  }

  /// 场景 `postcard` 上传一张图，返回可公开访问的 URL。
  Future<String> uploadPostcardImage({
    required Uint8List bytes,
    required String ext,
    String? contentType,
  }) async {
    final sign = await fetchPutSign(
      scene: 'postcard',
      ext: ext,
      contentType: contentType,
    );
    return uploadBytes(sign: sign, bytes: bytes);
  }
}
