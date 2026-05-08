import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_exception.dart';
import '../../core/mock/mock_models.dart';
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
}

MockUser _voToMockUser(Map<String, dynamic> m) {
  final id = (m['id'] as num?)?.toInt() ?? 0;
  final birthYear = (m['birthYear'] as num?)?.toInt() ?? 1970;
  final cc = (m['countryCode'] as String?) ?? '';
  return MockUser(
    id: '$id',
    nickname: (m['nickname'] as String?) ?? 'User',
    email: '',
    countryCode: cc,
    countryName: cc,
    birthYear: birthYear,
    bio: (m['bio'] as String?) ?? '',
    interests: const [],
    avatarUrl: m['avatarUrl'] as String?,
    isVip: m['isVip'] as bool? ?? false,
  );
}

final directoryRemoteProvider = Provider<DirectoryRemoteRepository>(
  (ref) => DirectoryRemoteRepository(ref.read(dioProvider)),
);
