import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_exception.dart';
import '../../core/network/dio_provider.dart';

/// 邮局首页 VO（对齐 `GET /api/post-office/home`）。
class PostOfficeHomeData {
  const PostOfficeHomeData({
    required this.greeting,
    required this.todayHint,
    required this.dailyLetterQuota,
    required this.sentToday,
    required this.relationMessageCount,
    required this.inTransitCount,
  });

  final String greeting;
  final String todayHint;
  final int dailyLetterQuota;
  final int sentToday;
  final int relationMessageCount;
  final int inTransitCount;

  int get remainingQuota {
    final left = dailyLetterQuota - sentToday;
    return left < 0 ? 0 : left;
  }
}

class PostOfficeRemoteRepository {
  PostOfficeRemoteRepository(this._dio);

  final Dio _dio;

  /// GET `/api/post-office/home`
  Future<PostOfficeHomeData> fetchHome() async {
    try {
      final r = await _dio.get<Map<String, dynamic>>('/api/post-office/home');
      final raw = r.data;
      if (raw is! Map<String, dynamic>) {
        throw ApiBusinessException(0, 'Invalid post-office home response');
      }
      final data = raw['data'];
      if (data is! Map<String, dynamic>) {
        throw ApiBusinessException(0, 'Invalid post-office home data');
      }
      return PostOfficeHomeData(
        greeting: (data['greeting'] as String?) ?? '',
        todayHint: (data['todayHint'] as String?) ?? '',
        dailyLetterQuota: (data['dailyLetterQuota'] as num?)?.toInt() ?? 5,
        sentToday: (data['sentToday'] as num?)?.toInt() ?? 0,
        relationMessageCount:
            (data['relationMessageCount'] as num?)?.toInt() ?? 0,
        inTransitCount: (data['inTransitCount'] as num?)?.toInt() ?? 0,
      );
    } on DioException catch (e) {
      debugPrint('post-office home failed: $e');
      final err = e.error;
      if (err is ApiBusinessException) rethrow;
      throw ApiBusinessException(0, e.message ?? 'Network error');
    }
  }
}

final postOfficeRemoteRepositoryProvider = Provider<PostOfficeRemoteRepository>(
  (ref) => PostOfficeRemoteRepository(ref.read(dioProvider)),
);

final postOfficeHomeProvider = FutureProvider<PostOfficeHomeData>((ref) async {
  return ref.read(postOfficeRemoteRepositoryProvider).fetchHome();
});
