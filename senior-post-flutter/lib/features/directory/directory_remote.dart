import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_exception.dart';
import '../../core/mock/mock_data.dart';
import '../../core/mock/mock_models.dart';
import '../../core/models/interest_tag_option.dart';
import '../../core/network/dio_provider.dart';

class DirectoryRemoteRepository {
  DirectoryRemoteRepository(this._dio);

  final Dio _dio;

  Future<List<MockUser>> pageUsers({
    required int page,
    required int size,
    String? countryCode,
    int? minAge,
    int? maxAge,
    List<String> interestNames = const [],
    String sort = 'DEFAULT',
  }) async {
    final r = await _dio.post<dynamic>(
      '/api/directory/users/paging',
      data: <String, dynamic>{
        'page': <String, dynamic>{'page': page, 'size': size},
        if (countryCode != null && countryCode.isNotEmpty) 'countryCode': countryCode,
        if (minAge != null) 'minAge': minAge,
        if (maxAge != null) 'maxAge': maxAge,
        if (interestNames.isNotEmpty) 'interestNames': interestNames,
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
    return rows.whereType<Map<String, dynamic>>().map(_voToMockUser).toList();
  }

  /// 名录公开用户卡（与分页 VO 字段一致）。不可见或不存在时返回 `null`。
  Future<MockUser?> getDirectoryUser(String userId) async {
    if (int.tryParse(userId) == null) {
      return null;
    }
    try {
      final r = await _dio.get<dynamic>('/api/directory/users/$userId');
      return unwrapData(r, (raw) {
        if (raw is! Map<String, dynamic>) {
          throw ApiBusinessException(0, 'Invalid user payload');
        }
        return _voToMockUser(raw);
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
  Future<List<InterestTagOption>> listInterestTagOptions({required String lang}) async {
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

  /// 与 `sys_tag.tag_name` 一致，供筛选 `interestNames` 使用。
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
}

MockUser _voToMockUser(Map<String, dynamic> m) {
  final id = (m['id'] as num?)?.toInt() ?? 0;
  final birthYear = (m['birthYear'] as num?)?.toInt() ?? 1970;
  final cc = (m['countryCode'] as String?) ?? '';
  var countryName = cc;
  for (final c in MockData.countries) {
    if (c.code == cc) {
      countryName = c.nameEn;
      break;
    }
  }
  var interestNames = const <String>[];
  final namesRaw = m['interestTagNames'];
  if (namesRaw is List<dynamic>) {
    interestNames = namesRaw
        .whereType<String>()
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }
  var interestIds = const <int>[];
  final idsRaw = m['interestTagIds'];
  if (idsRaw is List<dynamic>) {
    interestIds = idsRaw.whereType<num>().map((e) => e.toInt()).toList();
  }
  return MockUser(
    id: '$id',
    nickname: (m['nickname'] as String?) ?? 'User',
    email: '',
    countryCode: cc,
    countryName: countryName,
    birthYear: birthYear,
    bio: (m['bio'] as String?) ?? '',
    interests: interestNames,
    interestTagIds: interestIds,
    avatarUrl: m['avatarUrl'] as String?,
    isVip: m['isVip'] as bool? ?? false,
  );
}

final directoryRemoteProvider = Provider<DirectoryRemoteRepository>(
  (ref) => DirectoryRemoteRepository(ref.read(dioProvider)),
);
