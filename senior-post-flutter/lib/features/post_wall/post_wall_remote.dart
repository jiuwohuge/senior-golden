import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_exception.dart';
import '../../core/models/domain_models.dart';
import '../../core/network/dio_provider.dart';

/// 与 `/api/postcards/*` 对齐。
class PostWallRemoteRepository {
  PostWallRemoteRepository(this._dio);

  final Dio _dio;

  Future<List<WallPost>> listWall({int page = 1, int size = 50}) async {
    final r = await _dio.post<dynamic>(
      '/api/postcards/paging',
      data: <String, dynamic>{
        'page': <String, dynamic>{'page': page, 'size': size},
      },
    );
    final pd = _unwrapPageData(r);
    final rows = _recordsList(pd);
    return rows.whereType<Map<String, dynamic>>().map(_voToWallPost).toList();
  }

  Future<WallPost?> getPost(String id) async {
    final r = await _dio.get<dynamic>('/api/postcards/$id');
    final map = _unwrapMapData(r);
    return _voToWallPost(map);
  }

  Future<List<WallComment>> listComments(String postcardId, {int page = 1, int size = 50}) async {
    final r = await _dio.post<dynamic>(
      '/api/postcards/$postcardId/comments/paging',
      data: <String, dynamic>{
        'page': <String, dynamic>{'page': page, 'size': size},
      },
    );
    final pd = _unwrapPageData(r);
    final rows = _recordsList(pd);
    return rows.whereType<Map<String, dynamic>>().map(_voToWallComment).toList();
  }

  Future<WallPost> createPost({
    required String content,
    List<String>? imageUrls,
  }) async {
    final r = await _dio.post<dynamic>(
      '/api/postcards',
      data: <String, dynamic>{
        'content': content,
        if (imageUrls != null && imageUrls.isNotEmpty) 'imageUrls': imageUrls,
      },
    );
    final map = _unwrapMapData(r);
    return _voToWallPost(map);
  }

  Future<List<WallPost>> listMinePostcards({int page = 1, int size = 50}) async {
    final r = await _dio.post<dynamic>(
      '/api/postcards/mine/paging',
      data: <String, dynamic>{
        'page': <String, dynamic>{'page': page, 'size': size},
      },
    );
    final pd = _unwrapPageData(r);
    final rows = _recordsList(pd);
    return rows.whereType<Map<String, dynamic>>().map(_voToWallPost).toList();
  }

  Future<void> createComment({
    required String postcardId,
    required String content,
  }) async {
    await _dio.post<dynamic>(
      '/api/postcards/$postcardId/comments',
      data: <String, dynamic>{'content': content},
    );
  }

  /// `targetType`: `postcard` | `comment`
  Future<void> submitReport({
    required String targetType,
    required int targetId,
    required String reason,
  }) async {
    await _dio.post<dynamic>(
      '/api/reports',
      data: <String, dynamic>{
        'targetType': targetType,
        'targetId': targetId,
        'reason': reason,
      },
    );
  }
}

final postWallRemoteProvider = Provider<PostWallRemoteRepository>(
  (ref) => PostWallRemoteRepository(ref.read(dioProvider)),
);

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
    throw ApiBusinessException(0, 'Expected page records list');
  }
  return rows;
}

AppUser _authorFromMap(Map<String, dynamic> a) {
  final uid = (a['userId'] as num?)?.toInt() ?? 0;
  final cc = (a['countryCode'] as String?) ?? '';
  return AppUser(
    id: '$uid',
    nickname: (a['nickname'] as String?) ?? 'User',
    email: '',
    countryCode: cc,
    countryName: (a['countryName'] as String?)?.isNotEmpty == true
        ? (a['countryName'] as String)
        : cc,
    birthYear: 1970,
    bio: '',
    interests: const [],
    avatarUrl: a['avatarUrl'] as String?,
    isVip: false,
  );
}

WallPost _voToWallPost(Map<String, dynamic> m) {
  final authorRaw = m['author'];
  final authorMap = authorRaw is Map<String, dynamic> ? authorRaw : <String, dynamic>{};
  final id = '${m['id'] ?? ''}';
  final published = _parseDate(m['publishedAt']) ?? DateTime.now();
  List<String>? urls;
  final rawUrls = m['imageUrls'];
  if (rawUrls is List<dynamic>) {
    urls = rawUrls.whereType<String>().map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (urls.isEmpty) {
      urls = null;
    }
  }
  final single = m['imageUrl'] as String?;
  return WallPost(
    id: id,
    author: _authorFromMap(authorMap),
    content: (m['content'] as String?) ?? '',
    createdAt: published,
    commentCount: (m['commentCount'] as num?)?.toInt() ?? 0,
    imageUrl: single ?? (urls != null && urls.isNotEmpty ? urls.first : null),
    imageUrls: urls,
    reviewStatus: (m['reviewStatus'] as num?)?.toInt(),
    postStatus: (m['postStatus'] as num?)?.toInt(),
  );
}

WallComment _voToWallComment(Map<String, dynamic> m) {
  final authorRaw = m['author'];
  final authorMap = authorRaw is Map<String, dynamic> ? authorRaw : <String, dynamic>{};
  return WallComment(
    id: '${m['id'] ?? ''}',
    author: _authorFromMap(authorMap),
    content: (m['content'] as String?) ?? '',
    createdAt: _parseDate(m['createdAt']) ?? DateTime.now(),
  );
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
