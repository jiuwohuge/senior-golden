import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/directory/directory_providers.dart';
import '../../features/mailbox/mailbox_providers.dart';
import '../../features/social/social_remote.dart';

/// Token 变更（登录 / 登出 / 850x 清凭证）后丢弃需鉴权的缓存，避免仍展示过期错误。
final invalidateAuthDataProvider = Provider<void Function()>((ref) {
  return () {
    ref.invalidate(directoryUsersProvider);
    ref.invalidate(mailboxArchiveProvider);
    ref.invalidate(mailboxLettersProvider);
    ref.invalidate(postalInboxLettersProvider);
    ref.invalidate(mailboxFriendsProvider);
    ref.invalidate(blockedUsersListProvider);
  };
});