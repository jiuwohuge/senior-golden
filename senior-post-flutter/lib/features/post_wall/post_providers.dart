import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_token.dart';
import '../../core/models/domain_models.dart';
import 'post_wall_remote.dart';

enum PostWallFeedScope { everyone, connections }

final postWallFeedScopeProvider = StateProvider<PostWallFeedScope>(
  (ref) => PostWallFeedScope.everyone,
);

final postWallListProvider = FutureProvider<List<WallPost>>((ref) async {
  ref.watch(authTokenProvider);
  final scope = ref.watch(postWallFeedScopeProvider);
  return ref.read(postWallRemoteProvider).listWall(
        connectionsOnly: scope == PostWallFeedScope.connections,
      );
});

final userPostcardsProvider =
    FutureProvider.family<List<WallPost>, UserPostcardsQuery>((ref, query) async {
  ref.watch(authTokenProvider);
  return ref.read(postWallRemoteProvider).listUserPostcards(
        userId: query.userId,
        page: query.page,
        size: query.pageSize,
      );
});

class UserPostcardsQuery {
  const UserPostcardsQuery({
    required this.userId,
    required this.page,
    this.pageSize = 1,
  });

  final String userId;
  final int page;
  final int pageSize;

  @override
  bool operator ==(Object other) =>
      other is UserPostcardsQuery &&
      other.userId == userId &&
      other.page == page &&
      other.pageSize == pageSize;

  @override
  int get hashCode => Object.hash(userId, page, pageSize);
}

final postDetailProvider = FutureProvider.family<WallPost?, String>((ref, id) async {
  ref.watch(authTokenProvider);
  return ref.read(postWallRemoteProvider).getPost(id);
});

final postCommentsProvider = FutureProvider.family<List<WallComment>, String>((ref, id) async {
  ref.watch(authTokenProvider);
  return ref.read(postWallRemoteProvider).listComments(id);
});

final myPostcardsProvider = FutureProvider<List<WallPost>>((ref) async {
  ref.watch(authTokenProvider);
  return ref.read(postWallRemoteProvider).listMinePostcards();
});
