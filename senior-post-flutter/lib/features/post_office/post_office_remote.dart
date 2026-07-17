import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_exception.dart';
import '../../core/models/domain_models.dart';
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
    this.quotaClaimedToday = false,
    this.remainingQuotaOverride,
    this.firstLetterDone = false,
  });

  final String greeting;
  final String todayHint;
  final int dailyLetterQuota;
  final int sentToday;
  final int relationMessageCount;
  final int inTransitCount;

  /// 今日是否已领取免费额度；未领取时发信会被服务端拦截。
  final bool quotaClaimedToday;

  /// 服务端直接给出的剩余额度（未领取时为 0）。
  final int? remainingQuotaOverride;

  final bool firstLetterDone;

  int get remainingQuota {
    if (remainingQuotaOverride != null) return remainingQuotaOverride!;
    if (!quotaClaimedToday) return 0;
    final left = dailyLetterQuota - sentToday;
    return left < 0 ? 0 : left;
  }
}

/// §11.4 在途明细条目（对齐 `PostOfficeInTransitItemVO`）。
class PostOfficeInTransitItem {
  const PostOfficeInTransitItem({
    required this.itemType,
    required this.letterId,
    required this.peer,
    this.sentTime,
    this.expectedArrivalTime,
    this.etaRelativeHours,
    this.progressRatio,
    this.preview = '',
  });

  /// 1=发出未达 2=收到未达 3=未读已送达
  final int itemType;
  final String letterId;
  final AppUser peer;
  final DateTime? sentTime;
  final DateTime? expectedArrivalTime;
  final double? etaRelativeHours;
  final double? progressRatio;
  final String preview;
}

class DailyQuotaClaimResult {
  const DailyQuotaClaimResult({
    required this.claimed,
    required this.dailyLetterQuota,
    required this.sentToday,
    required this.remainingQuota,
  });

  final bool claimed;
  final int dailyLetterQuota;
  final int sentToday;
  final int remainingQuota;
}

class PostOfficeRemoteRepository {
  PostOfficeRemoteRepository(this._dio);

  final Dio _dio;

  /// GET `/api/post-office/home`
  Future<PostOfficeHomeData> fetchHome() async {
    try {
      final r = await _dio.get<Map<String, dynamic>>('/api/post-office/home');
      final data = _unwrapMap(r);
      return PostOfficeHomeData(
        greeting: (data['greeting'] as String?) ?? '',
        todayHint: (data['todayHint'] as String?) ?? '',
        dailyLetterQuota: (data['dailyLetterQuota'] as num?)?.toInt() ?? 5,
        sentToday: (data['sentToday'] as num?)?.toInt() ?? 0,
        relationMessageCount:
            (data['relationMessageCount'] as num?)?.toInt() ?? 0,
        inTransitCount: (data['inTransitCount'] as num?)?.toInt() ?? 0,
        quotaClaimedToday: data['quotaClaimedToday'] as bool? ?? false,
        remainingQuotaOverride: (data['remainingQuota'] as num?)?.toInt(),
        firstLetterDone: data['firstLetterDone'] as bool? ?? false,
      );
    } on DioException catch (e) {
      debugPrint('post-office home failed: $e');
      final err = e.error;
      if (err is ApiBusinessException) rethrow;
      throw ApiBusinessException(0, e.message ?? 'Network error');
    }
  }

  /// POST `/api/post-office/quota/daily-claim`（幂等）
  Future<DailyQuotaClaimResult> claimDailyQuota() async {
    try {
      final r = await _dio.post<Map<String, dynamic>>(
        '/api/post-office/quota/daily-claim',
      );
      final data = _unwrapMap(r);
      return DailyQuotaClaimResult(
        claimed: data['claimed'] as bool? ?? true,
        dailyLetterQuota: (data['dailyLetterQuota'] as num?)?.toInt() ?? 5,
        sentToday: (data['sentToday'] as num?)?.toInt() ?? 0,
        remainingQuota: (data['remainingQuota'] as num?)?.toInt() ?? 0,
      );
    } on DioException catch (e) {
      debugPrint('post-office daily-claim failed: $e');
      final err = e.error;
      if (err is ApiBusinessException) rethrow;
      throw ApiBusinessException(0, e.message ?? 'Network error');
    }
  }

  /// GET `/api/post-office/in-transit`
  Future<List<PostOfficeInTransitItem>> fetchInTransit() async {
    try {
      final r = await _dio.get<dynamic>('/api/post-office/in-transit');
      final rows = _unwrapList(r);
      return rows.map(_mapInTransit).toList();
    } on DioException catch (e) {
      debugPrint('post-office in-transit failed: $e');
      final err = e.error;
      if (err is ApiBusinessException) rethrow;
      throw ApiBusinessException(0, e.message ?? 'Network error');
    }
  }
}

PostOfficeInTransitItem _mapInTransit(Map<String, dynamic> m) {
  final peerRaw = m['peer'];
  final peerMap = peerRaw is Map<String, dynamic>
      ? peerRaw
      : <String, dynamic>{};
  return PostOfficeInTransitItem(
    itemType: (m['itemType'] as num?)?.toInt() ?? 1,
    letterId: '${m['letterId'] ?? ''}',
    peer: AppUser.fromPublicVoJson(peerMap),
    sentTime: _parseDate(m['sentTime']),
    expectedArrivalTime: _parseDate(m['expectedArrivalTime']),
    etaRelativeHours: (m['etaRelativeHours'] as num?)?.toDouble(),
    progressRatio: (m['progressRatio'] as num?)?.toDouble(),
    preview: (m['preview'] as String?) ?? '',
  );
}

DateTime? _parseDate(Object? v) {
  if (v == null) return null;
  if (v is String && v.isNotEmpty) {
    return DateTime.tryParse(v.replaceAll(' ', 'T')) ?? DateTime.tryParse(v);
  }
  return null;
}

Map<String, dynamic> _unwrapMap(Response<dynamic> r) {
  final raw = r.data;
  if (raw is! Map<String, dynamic>) {
    throw ApiBusinessException(0, 'Invalid response shape');
  }
  final data = raw['data'];
  if (data is! Map<String, dynamic>) {
    throw ApiBusinessException(0, 'Expected object data');
  }
  return data;
}

List<Map<String, dynamic>> _unwrapList(Response<dynamic> r) {
  final raw = r.data;
  if (raw is! Map<String, dynamic>) {
    throw ApiBusinessException(0, 'Invalid response shape');
  }
  final data = raw['data'];
  if (data is! List<dynamic>) {
    throw ApiBusinessException(0, 'Expected list data');
  }
  return data.whereType<Map<String, dynamic>>().toList();
}

final postOfficeRemoteRepositoryProvider = Provider<PostOfficeRemoteRepository>(
  (ref) => PostOfficeRemoteRepository(ref.read(dioProvider)),
);

final postOfficeHomeProvider = FutureProvider<PostOfficeHomeData>((ref) async {
  return ref.read(postOfficeRemoteRepositoryProvider).fetchHome();
});

/// 在途明细：离开页面自动释放，避免寄信后仍展示旧缓存。
final postOfficeInTransitProvider =
    FutureProvider.autoDispose<List<PostOfficeInTransitItem>>((ref) async {
      return ref.read(postOfficeRemoteRepositoryProvider).fetchInTransit();
    });
