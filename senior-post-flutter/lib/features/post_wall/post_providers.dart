import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/env/app_env.dart';
import '../../core/mock/mock_models.dart';
import '../../core/mock/mock_repository.dart';
import 'post_wall_remote.dart';

/// 明信片墙列表：Mock 走内存仓库；非 Mock 走 `/api/postcards/paging`。
final postWallListProvider = FutureProvider<List<MockPost>>((ref) async {
  if (AppEnv.useMock) {
    return ref.read(mockPostsRepositoryProvider).list();
  }
  return ref.read(postWallRemoteProvider).listWall();
});

final postDetailProvider = FutureProvider.family<MockPost?, String>((ref, id) async {
  if (AppEnv.useMock) {
    return ref.read(mockPostsRepositoryProvider).findById(id);
  }
  return ref.read(postWallRemoteProvider).getPost(id);
});

final postCommentsProvider = FutureProvider.family<List<MockComment>, String>((ref, id) async {
  if (AppEnv.useMock) {
    return ref.read(mockPostsRepositoryProvider).comments(id);
  }
  return ref.read(postWallRemoteProvider).listComments(id);
});
