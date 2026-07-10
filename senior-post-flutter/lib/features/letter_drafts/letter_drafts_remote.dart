import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_exception.dart';
import '../../core/models/domain_models.dart';
import '../../core/network/dio_provider.dart';
import '../mailbox/mailbox_remote.dart';

/// 与 `/api/letter-drafts` 对齐。
class LetterDraftsRemoteRepository {
  LetterDraftsRemoteRepository(this._dio);

  final Dio _dio;

  Future<List<LetterDraft>> listDrafts() async {
    final r = await _dio.get<dynamic>('/api/letter-drafts');
    return _unwrapList(r).map(_mapDraft).toList();
  }

  Future<LetterDraft> saveDraft({
    String? id,
    required String mode,
    String? toUserId,
    required String content,
    LetterType letterType = LetterType.standard,
  }) async {
    final r = await _dio.post<dynamic>(
      '/api/letter-drafts/save',
      data: <String, dynamic>{
        if (id != null && id.isNotEmpty) 'id': int.parse(id),
        'mode': mode,
        if (toUserId != null && toUserId.isNotEmpty)
          'toUserId': int.parse(toUserId),
        'contentJson': <String, dynamic>{
          'content': content,
          // M6：草稿也固定 STANDARD，不再写入挂号。
          'letterType': 2,
        },
      },
    );
    return _mapDraft(_unwrapMap(r));
  }

  Future<void> deleteDraft(String id) async {
    await _dio.delete<dynamic>('/api/letter-drafts/${int.parse(id)}');
  }

  /// 发送草稿：转正式发信并返回信箱条目。
  Future<MailboxLetter> sendDraft(String id) async {
    final r = await _dio.post<dynamic>(
      '/api/letter-drafts/${int.parse(id)}/send',
    );
    return voToMailboxLetter(_unwrapMap(r));
  }
}

LetterDraft _mapDraft(Map<String, dynamic> m) {
  final contentJson = m['contentJson'];
  var content = '';
  var letterType = LetterType.standard;
  if (contentJson is Map<String, dynamic>) {
    content = (contentJson['content'] as String?) ?? '';
    final lt = (contentJson['letterType'] as num?)?.toInt() ?? 2;
    letterType = lt == 1 ? LetterType.registered : LetterType.standard;
  }
  return LetterDraft(
    id: '${m['id'] ?? ''}',
    mode: (m['mode'] as String?) ?? 'DIRECT',
    toUserId: m['toUserId']?.toString(),
    content: content,
    letterType: letterType,
    updatedAt: _parseDate(m['updatedAt']),
  );
}

DateTime? _parseDate(Object? v) {
  if (v == null) return null;
  if (v is String && v.isNotEmpty) {
    return DateTime.tryParse(v.replaceAll(' ', 'T')) ?? DateTime.tryParse(v);
  }
  return null;
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

final letterDraftsRemoteProvider = Provider<LetterDraftsRemoteRepository>(
  (ref) => LetterDraftsRemoteRepository(ref.read(dioProvider)),
);

final letterDraftsProvider = FutureProvider<List<LetterDraft>>((ref) async {
  return ref.read(letterDraftsRemoteProvider).listDrafts();
});
