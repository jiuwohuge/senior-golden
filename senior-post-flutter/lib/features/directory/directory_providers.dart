import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_token.dart';
import '../../core/models/domain_models.dart';
import 'directory_remote.dart';

final directoryFilterProvider =
    StateProvider<DirectoryFilter>((ref) => const DirectoryFilter());

/// 名录列表走 `/api/directory/users/paging`（排序与筛选由服务端计算）。
final directoryUsersProvider = FutureProvider<List<AppUser>>((ref) async {
  ref.watch(authTokenProvider);
  final filter = ref.watch(directoryFilterProvider);
  return ref.read(directoryRemoteProvider).pageUsers(
        page: 1,
        size: 60,
        countryCode: filter.countryCode,
        minAge: filter.minAge,
        maxAge: filter.maxAge,
        interestNames: filter.interests.toList(),
        sort: filter.sort,
      );
});

class DirectoryFilter {
  const DirectoryFilter({
    this.countryCode,
    this.minAge = 45,
    this.maxAge = 80,
    this.interests = const {},
    this.sort = 'DEFAULT',
  });

  final String? countryCode;
  final int minAge;
  final int maxAge;
  final Set<String> interests;
  final String sort;

  DirectoryFilter copyWith({
    String? countryCode,
    int? minAge,
    int? maxAge,
    Set<String>? interests,
    String? sort,
  }) {
    return DirectoryFilter(
      countryCode: countryCode ?? this.countryCode,
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      interests: interests ?? this.interests,
      sort: sort ?? this.sort,
    );
  }
}
