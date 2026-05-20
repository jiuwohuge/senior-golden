import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/directory/directory_providers.dart';
import '../../features/mailbox/mailbox_providers.dart';
import '../../features/post_wall/post_providers.dart';
import '../../features/profile/stamps_ledger_page.dart';
import '../../features/social/social_remote.dart';

/// Token 变更（登录 / 登出 / 850x 清凭证）后丢弃需鉴权的缓存，避免仍展示过期错误。
final invalidateAuthDataProvider = Provider<void Function()>((ref) {
  return () {
    ref.invalidate(postWallListProvider);
    ref.invalidate(myPostcardsProvider);
    ref.invalidate(directoryUsersProvider);
    ref.invalidate(mailboxArchiveProvider);
    ref.invalidate(mailboxLettersProvider);
    ref.invalidate(postalInboxLettersProvider);
    ref.invalidate(mailboxFriendsProvider);
    ref.invalidate(stampsLedgerProvider);
    ref.invalidate(blockedUsersListProvider);
  };
});
