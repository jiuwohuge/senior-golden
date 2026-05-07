import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_exception.dart';
import '../../core/mock/mock_models.dart';
import '../../core/network/dio_provider.dart';

/// 与 `POST /api/stamps/ledger/paging` 对齐（`USE_MOCK=false`）。
class StampsRemoteRepository {
  StampsRemoteRepository(this._dio);

  final Dio _dio;

  Future<List<MockStampLedgerEntry>> ledgerPage({int page = 1, int size = 40}) async {
    final r = await _dio.post<dynamic>(
      '/api/stamps/ledger/paging',
      data: <String, dynamic>{
        'page': <String, dynamic>{'page': page, 'size': size},
      },
    );
    final pd = _unwrapPageData(r);
    final rows = _recordsList(pd);
    return rows.whereType<Map<String, dynamic>>().map(_voToLedgerEntry).toList();
  }
}

final stampsRemoteProvider = Provider<StampsRemoteRepository>(
  (ref) => StampsRemoteRepository(ref.read(dioProvider)),
);

Map<String, dynamic> _unwrapPageData(Response<dynamic> r) {
  final raw = r.data;
  if (raw is! Map<String, dynamic>) {
    throw ApiBusinessException(0, 'Invalid response shape');
  }
  final data = raw['data'];
  if (data is! Map<String, dynamic>) {
    throw ApiBusinessException(0, 'Expected page data');
  }
  return data;
}

List<dynamic> _recordsList(Map<String, dynamic> pageData) {
  final rows = pageData['records'] ?? pageData['list'] ?? pageData['rows'];
  if (rows is! List<dynamic>) {
    return const [];
  }
  return rows;
}

MockStampLedgerEntry _voToLedgerEntry(Map<String, dynamic> m) {
  final id = m['id'];
  final reason = (m['reason'] as String?)?.trim();
  return MockStampLedgerEntry(
    id: id == null ? '' : '$id',
    title: (reason != null && reason.isNotEmpty) ? reason : '—',
    delta: (m['changeAmount'] as num?)?.toInt() ?? 0,
    balanceAfter: (m['balanceAfter'] as num?)?.toInt() ?? 0,
    at: _parseBackendDateTime(m['createdAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
  );
}

/// 后端 `application.yml`：`yyyy-MM-dd HH:mm:ss`。
DateTime? _parseBackendDateTime(Object? v) {
  if (v == null) return null;
  if (v is String) {
    final s = v.trim();
    if (s.length >= 19 && s[10] == ' ') {
      return DateTime.tryParse('${s.substring(0, 10)}T${s.substring(11)}');
    }
    return DateTime.tryParse(s);
  }
  return null;
}
