import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_token.dart';
import '../../core/models/domain_models.dart';
import 'post_wall_remote.dart';

final postWallListProvider = FutureProvider<List<WallPost>>((ref) async {
  ref.watch(authTokenProvider);
  return ref.read(postWallRemoteProvider).listWall();
});

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
