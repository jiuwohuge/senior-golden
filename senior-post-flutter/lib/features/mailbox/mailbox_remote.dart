import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_exception.dart';
import '../../core/models/domain_models.dart';
import '../../core/network/dio_provider.dart';

/// 与 `/api/mailbox/*`、`/api/stamps/balance` 对齐。
class MailboxRemoteRepository {
  MailboxRemoteRepository(this._dio);

  final Dio _dio;

  Future<List<MailboxLetter>> listPostalInbox() async {
    final r = await _dio.get<dynamic>('/api/mailbox/postal');
    final rows = _unwrapListData(r);
    return rows.map(_voToMailboxLetter).toList();
  }

  Future<List<MailboxLetter>> listArchive() async {
    final r = await _dio.get<dynamic>('/api/mailbox/archive');
    final rows = _unwrapListData(r);
    return rows.map(_voToMailboxLetter).toList();
  }

  Future<MailboxLetter?> getLetter(String letterId) async {
    final r = await _dio.get<dynamic>('/api/mailbox/letters/$letterId');
    final map = _unwrapMapData(r);
    return _voToMailboxLetter(map);
  }

  Future<MailboxLetter> sendLetter({
    required String toUserId,
    required String content,
    required LetterType type,
    String? parentLetterId,
  }) async {
    final body = <String, dynamic>{
      'toUserId': int.parse(toUserId),
      'content': content,
      'letterType': type == LetterType.registered ? 1 : 2,
    };
    if (parentLetterId != null && parentLetterId.isNotEmpty) {
      body['parentLetterId'] = int.parse(parentLetterId);
    }
    final r = await _dio.post<dynamic>(
      '/api/mailbox/letters/send',
      data: body,
    );
    final map = _unwrapMapData(r);
    return _voToMailboxLetter(map);
  }

  Future<void> acceptPostalContact(String letterId) async {
    await _dio.post<dynamic>(
      '/api/mailbox/letters/$letterId/accept-postal',
    );
  }

  Future<MailboxLetter> speedUp(String letterId) async {
    final r = await _dio.post<dynamic>(
      '/api/mailbox/letters/${int.parse(letterId)}/speed-up',
    );
    final map = _unwrapMapData(r);
    return _voToMailboxLetter(map);
  }

  Future<MailboxLetter> earlyOpen(String letterId) async {
    final r = await _dio.post<dynamic>(
      '/api/mailbox/letters/${int.parse(letterId)}/early-open',
    );
    final map = _unwrapMapData(r);
    return _voToMailboxLetter(map);
  }

  Future<List<FriendListRow>> listMailboxFriends() async {
    final r = await _dio.get<dynamic>('/api/mailbox/friends');
    final rows = _unwrapListData(r);
    return rows.map(_voToFriendRow).toList();
  }

  Future<bool> isFriendshipActive(String peerUserId) async {
    final r = await _dio.get<dynamic>(
      '/api/mailbox/peers/${int.parse(peerUserId)}/friendship-active',
    );
    final raw = r.data;
    if (raw is! Map<String, dynamic>) {
      throw ApiBusinessException(0, 'Invalid response shape');
    }
    final data = raw['data'];
    if (data is bool) {
      return data;
    }
    if (data is String) {
      return data.toLowerCase() == 'true';
    }
    throw ApiBusinessException(0, 'Invalid friendship response');
  }
}

class StampRemoteRepository {
  StampRemoteRepository(this._dio);

  final Dio _dio;

  Future<({int balance, bool isVip})> balance() async {
    final r = await _dio.get<dynamic>('/api/stamps/balance');
    final map = _unwrapMapData(r);
    final bal = (map['stampsBalance'] as num?)?.toInt() ?? 0;
    final vip = map['isVip'] as bool? ?? false;
    return (balance: bal, isVip: vip);
  }
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

AppUser _peerToAppUser(Map<String, dynamic> p) {
  final id = (p['id'] as num?)?.toInt() ?? 0;
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
  final peerId = (m['peerUserId'] as num?)?.toInt() ?? 0;
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
  final sub = cc.isNotEmpty ? cc : 'Postal friend · tap to chat';
  return FriendListRow(
    peer: peer,
    lastMessage: sub,
    lastTime: connected,
  );
}

MailboxLetter _voToMailboxLetter(Map<String, dynamic> m) {
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
    1 => LetterStatus.delivering,
    3 => LetterStatus.registered,
    _ => LetterStatus.delivered,
  };
  final deliveryAt = st == LetterStatus.delivering
      ? expectedArrival
      : (actualArrival ?? expectedArrival);

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
  );
}

DateTime? _parseDate(Object? v) {
  if (v == null) {
    return null;
  }
  if (v is String) {
    return DateTime.tryParse(v.replaceAll(' ', 'T')) ??
        DateTime.tryParse(v);
  }
  return null;
}

final mailboxRemoteRepositoryProvider = Provider<MailboxRemoteRepository>(
  (ref) => MailboxRemoteRepository(ref.read(dioProvider)),
);

final stampRemoteRepositoryProvider = Provider<StampRemoteRepository>(
  (ref) => StampRemoteRepository(ref.read(dioProvider)),
);

/// 邮政 Tab 顶栏：`/api/stamps/balance`。
final mailboxStampHeaderProvider =
    FutureProvider<({int balance, int cap, bool isVip})>((ref) async {
  final row = await ref.read(stampRemoteRepositoryProvider).balance();
  return (balance: row.balance, cap: 3, isVip: row.isVip);
});

final friendshipActiveProvider = FutureProvider.family<bool, String>((
  ref,
  peerId,
) async {
  return ref.read(mailboxRemoteRepositoryProvider).isFriendshipActive(peerId);
});
