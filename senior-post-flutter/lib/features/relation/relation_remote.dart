import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_exception.dart';
import '../../core/models/domain_models.dart';
import '../../core/network/dio_provider.dart';

class RelationRemoteRepository {
  RelationRemoteRepository(this._dio);

  final Dio _dio;

  Future<RelationSnapshot> relationWith(String peerUserId) async {
    final r = await _dio.get<dynamic>('/api/relation/with/$peerUserId');
    return _mapSnapshot(_unwrapMap(r));
  }

  Future<void> createPenpalRequest({
    required String peerUserId,
    String? sourceLetterId,
  }) async {
    await _dio.post<dynamic>(
      '/api/relation/penpal/requests',
      data: <String, dynamic>{
        'peerUserId': int.parse(peerUserId),
        if (sourceLetterId != null && sourceLetterId.isNotEmpty)
          'sourceLetterId': int.parse(sourceLetterId),
      },
    );
  }

  Future<void> acceptPenpalRequest(String requestId) async {
    await _dio.post<dynamic>('/api/relation/penpal/requests/$requestId/accept');
  }

  Future<void> ignorePenpalRequest(String requestId) async {
    await _dio.post<dynamic>('/api/relation/penpal/requests/$requestId/ignore');
  }

  Future<List<PostOfficeRelationMessage>> listRelationMessages() async {
    final r = await _dio.get<dynamic>('/api/post-office/relation-messages');
    return _unwrapList(r).map(_mapRelationMessage).toList();
  }

  Future<ProfileOverview> fetchProfileOverview() async {
    final r = await _dio.get<dynamic>('/api/profile/overview');
    final m = _unwrapMap(r);
    return ProfileOverview(
      penpalCount: (m['penpalCount'] as num?)?.toInt() ?? 0,
      letterCount: (m['letterCount'] as num?)?.toInt() ?? 0,
      timeLetterCount: (m['timeLetterCount'] as num?)?.toInt() ?? 0,
    );
  }
}

RelationSnapshot _mapSnapshot(Map<String, dynamic> m) {
  final peerId = '${m['peerUserId'] ?? ''}';
  return RelationSnapshot(
    peerUserId: peerId,
    displayState:
        RelationDisplayState.fromCode((m['displayState'] as num?)?.toInt()) ??
        RelationDisplayState.stranger,
    letterCount: (m['letterCount'] as num?)?.toInt() ?? 0,
    canAddPenpal: m['canAddPenpal'] as bool? ?? false,
    pendingRequestId: m['pendingRequestId']?.toString(),
    penpal: m['penpal'] as bool? ?? false,
  );
}

PostOfficeRelationMessage _mapRelationMessage(Map<String, dynamic> m) {
  final peerRaw = m['peer'];
  final peerMap = peerRaw is Map<String, dynamic>
      ? peerRaw
      : <String, dynamic>{};
  return PostOfficeRelationMessage(
    messageType: (m['messageType'] as num?)?.toInt() ?? 0,
    requestId: m['requestId']?.toString(),
    peer: AppUser.fromPublicVoJson(peerMap),
    letterCount: (m['letterCount'] as num?)?.toInt() ?? 0,
    canAddPenpal: m['canAddPenpal'] as bool? ?? false,
  );
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

final relationRemoteProvider = Provider<RelationRemoteRepository>(
  (ref) => RelationRemoteRepository(ref.read(dioProvider)),
);

final relationWithProvider = FutureProvider.autoDispose
    .family<RelationSnapshot, String>((ref, peerId) async {
      return ref.read(relationRemoteProvider).relationWith(peerId);
    });

final postOfficeRelationMessagesProvider =
    FutureProvider<List<PostOfficeRelationMessage>>((ref) async {
      return ref.read(relationRemoteProvider).listRelationMessages();
    });

final profileOverviewProvider = FutureProvider<ProfileOverview>((ref) async {
  return ref.read(relationRemoteProvider).fetchProfileOverview();
});
