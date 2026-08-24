import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_exception.dart';
import '../../core/models/domain_models.dart';
import '../../core/network/dio_provider.dart';

/// 与 `/api/mailbox/*` 对齐。邮票展示与 `/api/auth/me` 会话态一致（见 `appSessionProvider`）。
class MailboxRemoteRepository {
  MailboxRemoteRepository(this._dio);

  final Dio _dio;

  Future<List<MailboxLetter>> listPostalInbox() async {
    final r = await _dio.get<dynamic>('/api/mailbox/postal');
    final rows = _unwrapListData(r);
    return rows.map(voToMailboxLetter).toList();
  }

  Future<List<MailboxLetter>> listReceived() async {
    final r = await _dio.get<dynamic>('/api/mailbox/received');
    return _unwrapListData(r).map(voToMailboxLetter).toList();
  }

  Future<List<MailboxLetter>> listSent() async {
    final r = await _dio.get<dynamic>('/api/mailbox/sent');
    return _unwrapListData(r).map(voToMailboxLetter).toList();
  }

  Future<List<MailboxLetter>> listArchive() async {
    final r = await _dio.get<dynamic>('/api/mailbox/archive');
    final rows = _unwrapListData(r);
    return rows.map(voToMailboxLetter).toList();
  }

  Future<MailboxLetter?> getLetter(String letterId) async {
    final r = await _dio.get<dynamic>('/api/mailbox/letters/$letterId');
    final map = _unwrapMapData(r);
    return voToMailboxLetter(map);
  }

  Future<MailboxLetter> sendLetter({
    String? toUserId,
    required String content,
    LetterType type = LetterType.standard,
    String? parentLetterId,
    int? mode,
    String? skinId,
    String? fontId,
    String? fontSizeTier,
    String? templateId,
    int? topicTagId,
  }) async {
    // M6：产品面废弃平邮/挂号选项，发信固定 STANDARD(2)。
    final body = <String, dynamic>{
      'content': content,
      'letterType': 2,
    };
    if (toUserId != null && toUserId.isNotEmpty) {
      body['toUserId'] = int.parse(toUserId);
    }
    if (mode != null) {
      body['mode'] = mode;
    }
    if (parentLetterId != null && parentLetterId.isNotEmpty) {
      body['parentLetterId'] = int.parse(parentLetterId);
    }
    if (skinId != null && skinId.isNotEmpty) {
      body['skinId'] = skinId;
    }
    if (fontId != null && fontId.isNotEmpty) {
      body['fontId'] = fontId;
    }
    if (fontSizeTier != null && fontSizeTier.isNotEmpty) {
      body['fontSizeTier'] = fontSizeTier;
    }
    if (templateId != null && templateId.isNotEmpty) {
      body['templateId'] = templateId;
    }
    // 未贴邮票不传该键，避免服务端把 0/空串当非法 id。
    if (topicTagId != null) {
      body['topicTagId'] = topicTagId;
    }
    // 保留 type 参数以兼容旧调用方；值不再影响请求体。
    assert(type == LetterType.standard || type == LetterType.registered);
    final r = await _dio.post<dynamic>('/api/mailbox/letters/send', data: body);
    final map = _unwrapMapData(r);
    return voToMailboxLetter(map);
  }

  Future<void> acceptPostalContact(String letterId) async {
    await _dio.post<dynamic>('/api/mailbox/letters/$letterId/accept-postal');
  }

  /// POST `/api/mailbox/letters/letter-assistant`：整理建议稿或灵感话题，不落库。
  Future<LetterAssistantResult> letterAssistant({
    required String sourceText,
    required String helpMode,
  }) async {
    final r = await _dio.post<dynamic>(
      '/api/mailbox/letters/letter-assistant',
      data: <String, dynamic>{
        // 空白信纸的灵感：空串可能被校验丢掉，空格到服务端 trim 后仍按未落笔处理。
        'sourceText': sourceText.trim().isEmpty ? ' ' : sourceText,
        'helpMode': helpMode,
      },
    );
    final map = _unwrapMapData(r);
    final suggestion = (map['suggestion'] as String?)?.trim() ?? '';
    final ask = _stringList(map['inspireAsk']);
    final share = _stringList(map['inspireShare']);
    if (suggestion.isEmpty && ask.isEmpty && share.isEmpty) {
      throw ApiBusinessException(0, 'Empty assistant suggestion');
    }
    return LetterAssistantResult(
      helpMode: (map['helpMode'] as String?)?.trim() ?? helpMode,
      suggestion: suggestion,
      inspireAsk: ask,
      inspireShare: share,
    );
  }

  static List<String> _stringList(Object? raw) {
    if (raw is! List<dynamic>) return const [];
    return raw
        .map((e) => e?.toString().trim() ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
  }

  Future<List<FriendListRow>> listMailboxFriends() async {
    final r = await _dio.get<dynamic>('/api/mailbox/friends');
    final rows = _unwrapListData(r);
    return rows.map(_voToFriendRow).toList();
  }

  Future<void> favoriteLetter(String letterId) async {
    await _dio.post<dynamic>('/api/letters/${int.parse(letterId)}/favorite');
  }

  Future<void> unfavoriteLetter(String letterId) async {
    await _dio.delete<dynamic>('/api/letters/${int.parse(letterId)}/favorite');
  }

  Future<List<MailboxLetter>> listFavoriteLetters() async {
    final r = await _dio.get<dynamic>('/api/letters/favorites');
    return _unwrapListData(r).map(voToMailboxLetter).toList();
  }

  Future<LetterExportResult> exportLetters({
    String? peerUserId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final body = <String, dynamic>{};
    if (peerUserId != null && peerUserId.isNotEmpty) {
      body['peerUserId'] = int.parse(peerUserId);
    }
    if (fromDate != null) {
      body['fromDate'] = _formatDate(fromDate);
    }
    if (toDate != null) {
      body['toDate'] = _formatDate(toDate);
    }
    final r = await _dio.post<dynamic>('/api/letters/export', data: body);
    final map = _unwrapMapData(r);
    return LetterExportResult(downloadUrl: map['downloadUrl'] as String?);
  }
}

String _formatDate(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}

List<Map<String, dynamic>> _unwrapListData(Response<dynamic> r) {
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

Map<String, dynamic> _unwrapMapData(Response<dynamic> r) {
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

int? _readIntLoose(Object? v) {
  if (v == null) {
    return null;
  }
  if (v is int) {
    return v;
  }
  if (v is num) {
    return v.toInt();
  }
  if (v is String) {
    return int.tryParse(v.trim());
  }
  return null;
}

AppUser _peerToAppUser(Map<String, dynamic> p) {
  final id = _readIntLoose(p['id']) ?? 0;
  final birthYear = (p['birthYear'] as num?)?.toInt() ?? 1970;
  return AppUser(
    id: '$id',
    nickname: (p['nickname'] as String?) ?? 'User',
    email: (p['email'] as String?) ?? '',
    countryCode: (p['countryCode'] as String?) ?? '',
    countryName: (p['countryCode'] as String?) ?? '',
    birthYear: birthYear,
    bio: (p['bio'] as String?) ?? '',
    interests: const [],
    avatarUrl: p['avatarUrl'] as String?,
    isVip: p['isVip'] as bool? ?? false,
  );
}

FriendListRow _voToFriendRow(Map<String, dynamic> m) {
  final peerId = _readIntLoose(m['peerUserId'] ?? m['peer_user_id']) ?? 0;
  final nick = (m['peerNickname'] as String?) ?? 'User';
  final cc = (m['peerCountryCode'] as String?) ?? '';
  final connected = _parseDate(m['connectedAt']) ?? DateTime.now();
  final peer = AppUser(
    id: '$peerId',
    nickname: nick,
    email: '',
    countryCode: cc,
    countryName: cc,
    birthYear: 1970,
    bio: '',
    interests: const [],
    avatarUrl: m['peerAvatarUrl'] as String?,
    isVip: false,
  );
  final sub = cc.isNotEmpty ? cc : 'Postal friend';
  return FriendListRow(peer: peer, lastMessage: sub, lastTime: connected);
}

MailboxLetter voToMailboxLetter(Map<String, dynamic> m) {
  final peer = m['peer'];
  final peerMap = peer is Map<String, dynamic> ? peer : <String, dynamic>{};
  final letterId = '${m['letterId'] ?? m['id'] ?? ''}';
  final letterType = (m['letterType'] as num?)?.toInt() ?? 2;
  final status = (m['status'] as num?)?.toInt() ?? 1;
  final sendMode = (m['sendMode'] as num?)?.toInt() ?? 1;
  final preview = (m['preview'] as String?) ?? '';
  final content = (m['content'] as String?) ?? preview;
  final fromMe = m['fromMe'] as bool? ?? true;
  final sentAt = _parseDate(m['sentAt']) ?? DateTime.now();
  final contentHidden = m['contentHidden'] as bool? ?? false;
  final expectedArrival = _parseDate(m['expectedArrivalTime']);
  final actualArrival = _parseDate(m['actualArrivalTime']);
  final st = switch (status) {
    0 => LetterStatus.pending,
    1 => LetterStatus.delivering,
    3 => LetterStatus.registered,
    4 => LetterStatus.matched,
    _ => LetterStatus.delivered,
  };
  final deliveryAt = st == LetterStatus.delivering || st == LetterStatus.pending
      ? expectedArrival
      : (actualArrival ?? expectedArrival);
  final modeCode = (m['mode'] as num?)?.toInt() ?? 2;
  final mode = switch (modeCode) {
    1 => LetterMode.postOffice,
    3 => LetterMode.selfTime,
    _ => LetterMode.direct,
  };

  return MailboxLetter(
    id: letterId,
    peer: _peerToAppUser(peerMap),
    preview: preview,
    body: content,
    type: letterType == 1 ? LetterType.registered : LetterType.standard,
    status: st,
    sentAt: sentAt,
    deliveryAt: deliveryAt,
    outgoing: fromMe,
    sendMode: switch (sendMode) {
      2 => LetterSendMode.registeredMail,
      3 => LetterSendMode.directVip,
      _ => LetterSendMode.standardPost,
    },
    contentHidden: contentHidden,
    expectedArrivalAt: expectedArrival,
    actualArrivalAt: actualArrival,
    mode: mode,
    auditStatus: (m['auditStatus'] as num?)?.toInt() ?? 1,
    relationDisplayState: RelationDisplayState.fromCode(
      (m['relationDisplayState'] as num?)?.toInt(),
    ),
    canAddPenpal: m['canAddPenpal'] as bool? ?? false,
    recipientRead: m['recipientRead'] as bool? ?? false,
    fromCountryName: m['fromCountryName'] as String?,
    toCountryName: m['toCountryName'] as String?,
    postmarkLabel: m['postmarkLabel'] as String?,
    skinId: m['skinId'] as String?,
    fontId: m['fontId'] as String?,
    fontSizeTier: m['fontSizeTier'] as String?,
    favorited: m['favorited'] as bool? ?? false,
  );
}

/// 信件助手 API 结果（润色正文或灵感话题列表）。
class LetterAssistantResult {
  const LetterAssistantResult({
    required this.helpMode,
    required this.suggestion,
    this.inspireAsk = const [],
    this.inspireShare = const [],
  });

  final String helpMode;
  final String suggestion;
  final List<String> inspireAsk;
  final List<String> inspireShare;

  bool get isInspire =>
      helpMode == 'inspire' || inspireAsk.isNotEmpty || inspireShare.isNotEmpty;
}

DateTime? _parseDate(Object? v) {
  if (v == null) {
    return null;
  }
  if (v is String) {
    return DateTime.tryParse(v.replaceAll(' ', 'T')) ?? DateTime.tryParse(v);
  }
  return null;
}

final mailboxRemoteRepositoryProvider = Provider<MailboxRemoteRepository>(
  (ref) => MailboxRemoteRepository(ref.read(dioProvider)),
);

final letterFavoritesProvider = FutureProvider<List<MailboxLetter>>((
  ref,
) async {
  return ref.read(mailboxRemoteRepositoryProvider).listFavoriteLetters();
});
