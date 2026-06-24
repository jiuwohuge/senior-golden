import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_exception.dart';
import '../../core/network/dio_provider.dart';
import '../../core/time/backend_date_format.dart';

final timeLetterRemoteProvider = Provider<TimeLetterRemoteRepository>((ref) {
  return TimeLetterRemoteRepository(ref.watch(dioProvider));
});

class TimeLetterItem {
  TimeLetterItem({
    required this.id,
    required this.status,
    this.senderId,
    this.recipientId,
    this.recipientType,
    this.bodyPreview,
    this.deliveryDate,
    this.deliveryTz,
    this.sealedAt,
    this.deliveredAt,
    this.readAt,
    this.cancelDeadlineAt,
    this.starFlag = false,
    this.peerNickname,
    this.peerAvatarUrl,
    this.daysUntilDelivery,
    this.canCancel = false,
    this.contentTag,
    this.emotionTag,
  });

  final String id;
  final int status;
  final String? senderId;
  final String? recipientId;
  final int? recipientType;
  final String? bodyPreview;
  final String? deliveryDate;
  final String? deliveryTz;
  final String? sealedAt;
  final String? deliveredAt;
  final String? readAt;
  final String? cancelDeadlineAt;
  final bool starFlag;
  final String? peerNickname;
  final String? peerAvatarUrl;
  final int? daysUntilDelivery;
  final bool canCancel;
  final String? contentTag;
  final String? emotionTag;
}

class TimeLetterDetail {
  TimeLetterDetail({
    required this.id,
    required this.status,
    this.body,
    this.senderId,
    this.recipientId,
    this.recipientType,
    this.deliveryDate,
    this.deliveryTz,
    this.sealedAt,
    this.deliveredAt,
    this.readAt,
    this.cancelDeadlineAt,
    this.starFlag = false,
    this.senderNickname,
    this.senderAvatarUrl,
    this.recipientNickname,
    this.recipientAvatarUrl,
    this.canCancel = false,
    this.canOpen = false,
    this.estimatedReadMinutes,
    this.contentTag,
    this.emotionTag,
    this.paperTheme,
    this.paperColor,
    this.writerCity,
  });

  final String id;
  final int status;
  final String? body;
  final String? senderId;
  final String? recipientId;
  final int? recipientType;
  final String? deliveryDate;
  final String? deliveryTz;
  final String? sealedAt;
  final String? deliveredAt;
  final String? readAt;
  final String? cancelDeadlineAt;
  final bool starFlag;
  final String? senderNickname;
  final String? senderAvatarUrl;
  final String? recipientNickname;
  final String? recipientAvatarUrl;
  final bool canCancel;
  final bool canOpen;
  final int? estimatedReadMinutes;
  final String? contentTag;
  final String? emotionTag;
  final String? paperTheme;
  final String? paperColor;
  final String? writerCity;
}

class TimeLetterStats {
  const TimeLetterStats({
    this.inFlightCount = 0,
    this.deliveredUnreadCount = 0,
    this.memorialCount = 0,
    this.todayDeliveredCount = 0,
  });

  final int inFlightCount;
  final int deliveredUnreadCount;
  final int memorialCount;
  final int todayDeliveredCount;
}

class TimeLetterRecentRecipient {
  const TimeLetterRecentRecipient({
    required this.userId,
    this.nickname,
    this.avatarUrl,
    this.countryLabel,
  });

  final String userId;
  final String? nickname;
  final String? avatarUrl;
  final String? countryLabel;
}

class TimeLetterRemoteRepository {
  TimeLetterRemoteRepository(this._dio);

  final Dio _dio;

  Future<TimeLetterDetail> saveDraft({
    int? id,
    String? recipientId,
    required String body,
    required DateTime deliveryDate,
    required String deliveryTz,
    String? contentTag,
    String? emotionTag,
  }) async {
    final r = await _dio.post<dynamic>(
      '/api/time-letter/draft',
      data: <String, dynamic>{
        if (id != null) 'id': id,
        if (recipientId != null) 'recipientId': int.tryParse(recipientId),
        'body': body,
        'deliveryDate': formatBackendLocalDate(deliveryDate),
        'deliveryTz': deliveryTz,
        if (contentTag != null) 'contentTag': contentTag,
        if (emotionTag != null) 'emotionTag': emotionTag,
      },
    );
    return _detailFromMap(_unwrapMap(r));
  }

  Future<TimeLetterSealResult> seal({
    int? draftId,
    String? recipientId,
    required String body,
    required DateTime deliveryDate,
    required String deliveryTz,
    required String sealRequestId,
    String? contentTag,
    String? emotionTag,
  }) async {
    final r = await _dio.post<dynamic>(
      '/api/time-letter/seal',
      data: <String, dynamic>{
        if (draftId != null) 'draftId': draftId,
        if (recipientId != null) 'recipientId': int.tryParse(recipientId),
        'body': body,
        'deliveryDate': formatBackendLocalDate(deliveryDate),
        'deliveryTz': deliveryTz,
        'sealRequestId': sealRequestId,
        if (contentTag != null) 'contentTag': contentTag,
        if (emotionTag != null) 'emotionTag': emotionTag,
      },
    );
    final m = _unwrapMap(r);
    return TimeLetterSealResult(
      id: '${m['id']}',
      status: (m['status'] as num?)?.toInt() ?? 2,
      deliveryDate: m['deliveryDate']?.toString(),
      cancelDeadlineAt: m['cancelDeadlineAt']?.toString(),
      stampCost: (m['stampCost'] as num?)?.toInt(),
      stampBalanceAfter: (m['stampBalanceAfter'] as num?)?.toInt(),
    );
  }

  Future<void> cancel(String letterId) async {
    await _dio.post<dynamic>('/api/time-letter/$letterId/cancel');
  }

  Future<List<TimeLetterItem>> listOutbox({int page = 1, int size = 20}) async {
    return _listPaging('/api/time-letter/outbox/paging', page, size);
  }

  Future<List<TimeLetterItem>> listInbox({int page = 1, int size = 20}) async {
    return _listPaging('/api/time-letter/inbox/paging', page, size);
  }

  Future<List<TimeLetterItem>> listMemorial({
    int page = 1,
    int size = 20,
    bool starredOnly = false,
  }) async {
    return _listPaging(
      '/api/time-letter/memorial/paging',
      page,
      size,
      starredOnly: starredOnly,
    );
  }

  Future<TimeLetterDetail> getDetail(String id) async {
    final r = await _dio.get<dynamic>('/api/time-letter/$id');
    return _detailFromMap(_unwrapMap(r));
  }

  Future<TimeLetterDetail> open(String id) async {
    final r = await _dio.post<dynamic>('/api/time-letter/$id/open');
    return _detailFromMap(_unwrapMap(r));
  }

  Future<void> toggleStar(String id) async {
    await _dio.post<dynamic>('/api/time-letter/$id/star');
  }

  Future<TimeLetterStats> stats() async {
    final r = await _dio.get<dynamic>('/api/time-letter/stats');
    final m = _unwrapMap(r);
    return TimeLetterStats(
      inFlightCount: (m['inFlightCount'] as num?)?.toInt() ?? 0,
      deliveredUnreadCount: (m['deliveredUnreadCount'] as num?)?.toInt() ?? 0,
      memorialCount: (m['memorialCount'] as num?)?.toInt() ?? 0,
      todayDeliveredCount: (m['todayDeliveredCount'] as num?)?.toInt() ?? 0,
    );
  }

  Future<List<TimeLetterRecentRecipient>> recentRecipients() async {
    final r = await _dio.get<dynamic>('/api/time-letter/recent-recipients');
    final list = _unwrapList(r);
    return list.whereType<Map<String, dynamic>>().map((m) {
      return TimeLetterRecentRecipient(
        userId: '${m['userId']}',
        nickname: m['nickname'] as String?,
        avatarUrl: m['avatarUrl'] as String?,
        countryLabel: m['countryLabel'] as String?,
      );
    }).toList();
  }

  Future<int> previewDaysUntil(DateTime deliveryDate, String deliveryTz) async {
    final r = await _dio.post<dynamic>(
      '/api/time-letter/preview-delivery',
      data: <String, dynamic>{
        'deliveryDate': formatBackendLocalDate(deliveryDate),
        'deliveryTz': deliveryTz,
      },
    );
    final m = _unwrapMap(r);
    return (m['daysUntilDelivery'] as num?)?.toInt() ?? 0;
  }

  Future<List<TimeLetterItem>> _listPaging(
    String path,
    int page,
    int size, {
    bool starredOnly = false,
  }) async {
    final r = await _dio.post<dynamic>(
      path,
      data: <String, dynamic>{
        'page': <String, dynamic>{'page': page, 'size': size},
        if (starredOnly) 'starredOnly': true,
      },
    );
    final pd = _unwrapPageData(r);
    final rows = _recordsList(pd);
    return rows.whereType<Map<String, dynamic>>().map(_itemFromMap).toList();
  }

  static Map<String, dynamic> _unwrapMap(Response<dynamic> r) {
    final raw = r.data;
    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return raw;
    }
    throw ApiBusinessException(0, 'Invalid response');
  }

  static Map<String, dynamic> _unwrapPageData(Response<dynamic> r) {
    final raw = r.data;
    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
    }
    return <String, dynamic>{};
  }

  static List<dynamic> _recordsList(Map<String, dynamic> pd) {
    final records = pd['records'];
    if (records is List) return records;
    return const [];
  }

  static List<dynamic> _unwrapList(Response<dynamic> r) {
    final raw = r.data;
    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data is List) return data;
    }
    if (raw is List) return raw;
    return const [];
  }

  static TimeLetterItem _itemFromMap(Map<String, dynamic> m) {
    return TimeLetterItem(
      id: '${m['id']}',
      status: (m['status'] as num?)?.toInt() ?? 0,
      senderId: m['senderId']?.toString(),
      recipientId: m['recipientId']?.toString(),
      recipientType: (m['recipientType'] as num?)?.toInt(),
      bodyPreview: m['bodyPreview'] as String?,
      deliveryDate: m['deliveryDate']?.toString(),
      deliveryTz: m['deliveryTz'] as String?,
      sealedAt: m['sealedAt']?.toString(),
      deliveredAt: m['deliveredAt']?.toString(),
      readAt: m['readAt']?.toString(),
      cancelDeadlineAt: m['cancelDeadlineAt']?.toString(),
      starFlag: m['starFlag'] == true,
      peerNickname: m['peerNickname'] as String?,
      peerAvatarUrl: m['peerAvatarUrl'] as String?,
      daysUntilDelivery: (m['daysUntilDelivery'] as num?)?.toInt(),
      canCancel: m['canCancel'] == true,
      contentTag: m['contentTag'] as String?,
      emotionTag: m['emotionTag'] as String?,
    );
  }

  static TimeLetterDetail _detailFromMap(Map<String, dynamic> m) {
    return TimeLetterDetail(
      id: '${m['id']}',
      status: (m['status'] as num?)?.toInt() ?? 0,
      body: m['body'] as String?,
      senderId: m['senderId']?.toString(),
      recipientId: m['recipientId']?.toString(),
      recipientType: (m['recipientType'] as num?)?.toInt(),
      deliveryDate: m['deliveryDate']?.toString(),
      deliveryTz: m['deliveryTz'] as String?,
      sealedAt: m['sealedAt']?.toString(),
      deliveredAt: m['deliveredAt']?.toString(),
      readAt: m['readAt']?.toString(),
      cancelDeadlineAt: m['cancelDeadlineAt']?.toString(),
      starFlag: m['starFlag'] == true,
      senderNickname: m['senderNickname'] as String?,
      senderAvatarUrl: m['senderAvatarUrl'] as String?,
      recipientNickname: m['recipientNickname'] as String?,
      recipientAvatarUrl: m['recipientAvatarUrl'] as String?,
      canCancel: m['canCancel'] == true,
      canOpen: m['canOpen'] == true,
      estimatedReadMinutes: (m['estimatedReadMinutes'] as num?)?.toInt(),
      contentTag: m['contentTag'] as String?,
      emotionTag: m['emotionTag'] as String?,
      paperTheme: m['paperTheme'] as String?,
      paperColor: m['paperColor'] as String?,
      writerCity: m['writerCity'] as String?,
    );
  }
}

class TimeLetterSealResult {
  const TimeLetterSealResult({
    required this.id,
    required this.status,
    this.deliveryDate,
    this.cancelDeadlineAt,
    this.stampCost,
    this.stampBalanceAfter,
  });

  final String id;
  final int status;
  final String? deliveryDate;
  final String? cancelDeadlineAt;
  final int? stampCost;
  final int? stampBalanceAfter;
}
