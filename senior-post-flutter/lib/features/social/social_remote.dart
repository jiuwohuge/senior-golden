import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_exception.dart';
import '../../core/models/domain_models.dart';
import '../../core/network/dio_provider.dart';

/// 与 `/api/social/blocks`、`/api/feedback` 对齐。
class BlockListRow {
  const BlockListRow({
    required this.blockedUserId,
    required this.peer,
    this.blockedAt,
  });

  final String blockedUserId;
  final AppUser peer;
  final DateTime? blockedAt;

  static BlockListRow fromJson(Map<String, dynamic> m) {
    final id = (m['blockedUserId'] as num?)?.toInt() ?? 0;
    final peerRaw = m['peer'];
    if (peerRaw is! Map<String, dynamic>) {
      throw ApiBusinessException(0, 'Invalid block list item');
    }
    DateTime? blockedAt;
    final ba = m['blockedAt'];
    if (ba is String && ba.isNotEmpty) {
      blockedAt = DateTime.tryParse(ba);
    }
    return BlockListRow(
      blockedUserId: '$id',
      peer: AppUser.fromPublicVoJson(peerRaw),
      blockedAt: blockedAt,
    );
  }
}

class SocialRemoteRepository {
  SocialRemoteRepository(this._dio);

  final Dio _dio;

  Future<List<BlockListRow>> listBlocks() async {
    final r = await _dio.get<dynamic>('/api/social/blocks');
    return unwrapData(r, (raw) {
      if (raw is! List<dynamic>) {
        throw ApiBusinessException(0, 'Expected block list');
      }
      return raw
          .whereType<Map<String, dynamic>>()
          .map(BlockListRow.fromJson)
          .toList();
    });
  }

  Future<void> blockUser({
    required String blockedUserId,
    String? reason,
  }) async {
    final uid = int.tryParse(blockedUserId);
    if (uid == null || uid <= 0) {
      throw ApiBusinessException(0, 'Invalid user id');
    }
    await _dio.post<dynamic>(
      '/api/social/blocks',
      data: <String, dynamic>{
        'blockedUserId': uid,
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
    );
  }

  Future<void> unblockUser(String blockedUserId) async {
    final uid = int.tryParse(blockedUserId);
    if (uid == null || uid <= 0) {
      throw ApiBusinessException(0, 'Invalid user id');
    }
    await _dio.delete<dynamic>('/api/social/blocks/$uid');
  }

  Future<void> submitFeedback({
    required String content,
    String? clientVersion,
  }) async {
    await _dio.post<dynamic>(
      '/api/feedback',
      data: <String, dynamic>{
        'content': content,
        if (clientVersion != null && clientVersion.trim().isNotEmpty)
          'clientVersion': clientVersion.trim(),
      },
    );
  }
}

final socialRemoteProvider = Provider<SocialRemoteRepository>(
  (ref) => SocialRemoteRepository(ref.read(dioProvider)),
);

final blockedUsersListProvider = FutureProvider.autoDispose<List<BlockListRow>>(
  (ref) async {
    return ref.read(socialRemoteProvider).listBlocks();
  },
);
