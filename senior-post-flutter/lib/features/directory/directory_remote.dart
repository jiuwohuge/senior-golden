import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_exception.dart';
import '../../core/models/domain_models.dart';
import '../../core/models/interest_tag_option.dart';
import '../../core/network/dio_provider.dart';

class DirectoryRemoteRepository {
  DirectoryRemoteRepository(this._dio);

  final Dio _dio;

  Future<List<AppUser>> pageUsers({
    required int page,
    required int size,
    String? countryCode,
    int? minAge,
    int? maxAge,
    List<String> interestNames = const [],
    List<int> genders = const [],
    String sort = 'DEFAULT',
  }) async {
    final r = await _dio.post<dynamic>(
      '/api/directory/users/paging',
      data: <String, dynamic>{
        'page': <String, dynamic>{'page': page, 'size': size},
        if (countryCode != null && countryCode.isNotEmpty)
          'countryCode': countryCode,
        if (minAge != null) 'minAge': minAge,
        if (maxAge != null) 'maxAge': maxAge,
        if (interestNames.isNotEmpty) 'interestNames': interestNames,
        if (genders.isNotEmpty) 'genders': genders,
        if (sort.isNotEmpty) 'sort': sort,
      },
    );
    final raw = r.data;
    if (raw is! Map<String, dynamic>) {
      throw ApiBusinessException(0, 'Invalid response shape');
    }
    final data = raw['data'];
    if (data is! Map<String, dynamic>) {
      throw ApiBusinessException(0, 'Expected page data');
    }
    final rows = data['records'] ?? data['list'];
    if (rows is! List<dynamic>) {
      throw ApiBusinessException(0, 'Expected page records');
    }
    return rows.whereType<Map<String, dynamic>>().map(_voToAppUser).toList();
  }

  /// 名录公开用户卡（与分页 VO 字段一致）。不可见或不存在时返回 `null`。
  Future<AppUser?> getDirectoryUser(String userId) async {
    if (int.tryParse(userId) == null) {
      return null;
    }
    try {
      final r = await _dio.get<dynamic>('/api/directory/users/$userId');
      return unwrapData(r, (raw) {
        if (raw is! Map<String, dynamic>) {
          throw ApiBusinessException(0, 'Invalid user payload');
        }
        return _voToAppUser(raw);
      });
    } on DioException catch (e) {
      final err = e.error;
      if (err is ApiBusinessException) {
        final msg = err.message;
        if (msg.contains('用户不存在') || msg.contains('该用户暂不可见')) {
          return null;
        }
      }
      rethrow;
    }
  }

  /// 带 `id` 的选项，供资料编辑多选；筛选名录仍用 [listInterestTagNames] 的 `tag_name`。
  Future<List<InterestTagOption>> listInterestTagOptions({
    required String lang,
  }) async {
    final r = await _dio.get<dynamic>(
      '/api/directory/interest-tag-options',
      queryParameters: <String, dynamic>{'lang': lang},
    );
    return unwrapData(r, (raw) {
      if (raw is! List<dynamic>) {
        throw ApiBusinessException(0, 'Expected interest tag options');
      }
      return raw
          .whereType<Map<String, dynamic>>()
          .map(InterestTagOption.fromJson)
          .where((e) => e.id > 0 && e.tagName.isNotEmpty)
          .toList();
    });
  }

  Future<List<String>> listInterestTagNames({required String lang}) async {
    final r = await _dio.get<dynamic>(
      '/api/directory/interest-tags',
      queryParameters: <String, dynamic>{'lang': lang},
    );
    return unwrapData(r, (raw) {
      if (raw is! List<dynamic>) {
        throw ApiBusinessException(0, 'Expected interest tag list');
      }
      return raw
          .whereType<String>()
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    });
  }

  Future<List<AppUser>> listTodayRecommendations() async {
    final r = await _dio.get<dynamic>('/api/directory/recommendations/today');
    return unwrapData(r, (raw) {
      if (raw is! List<dynamic>) {
        throw ApiBusinessException(0, 'Expected recommendation list');
      }
      return raw.whereType<Map<String, dynamic>>().map(_voToAppUser).toList();
    });
  }

  Future<List<PenpalListItem>> listPenpals() async {
    final r = await _dio.get<dynamic>('/api/directory/penpals');
    return unwrapData(r, (raw) {
      if (raw is! List<dynamic>) {
        throw ApiBusinessException(0, 'Expected penpal list');
      }
      return raw.whereType<Map<String, dynamic>>().map(_voToPenpal).toList();
    });
  }
}

PenpalListItem _voToPenpal(Map<String, dynamic> m) {
  final id = (m['peerUserId'] as num?)?.toInt() ?? 0;
  DateTime? since;
  final s = m['penpalSince'];
  if (s is String && s.isNotEmpty) {
    since = DateTime.tryParse(s.replaceAll(' ', 'T')) ?? DateTime.tryParse(s);
  }
  return PenpalListItem(
    peerUserId: '$id',
    nickname: (m['nickname'] as String?) ?? 'User',
    avatarUrl: m['avatarUrl'] as String?,
    countryCode: m['countryCode'] as String?,
    letterCount: (m['letterCount'] as num?)?.toInt() ?? 0,
    penpalDays: (m['penpalDays'] as num?)?.toInt() ?? 0,
    penpalSince: since,
  );
}

AppUser _voToAppUser(Map<String, dynamic> m) {
  return AppUser.fromPublicVoJson(m);
}

final directoryRemoteProvider = Provider<DirectoryRemoteRepository>(
  (ref) => DirectoryRemoteRepository(ref.read(dioProvider)),
);
