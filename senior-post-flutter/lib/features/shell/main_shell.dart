import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';
import 'package:senior_post_flutter/widgets/postal_decorations.dart';

import '../post_office/post_office_home_page.dart';
import '../mailbox/mailbox_page.dart';
import '../profile/profile_page.dart';

/// 底部三 Tab：邮局 / 信箱 / 我的。笔友发现已从主导航撤出。
abstract final class MainShellRoute {
  static const pathPostOffice = '/';
  static const pathPenPals = '/penpals';
  static const pathMailbox = '/mailbox';
  static const pathProfile = '/profile';
}

/// 主壳：邮局保留邮戳顶栏；信箱 / 我的用短标题，把高度还给信件列表。
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, 2);
  }

  void _goBranch(int index) {
    setState(() => _index = index);
    if (!mounted) return;
    final loc = switch (index) {
      0 => MainShellRoute.pathPostOffice,
      1 => MainShellRoute.pathMailbox,
      _ => MainShellRoute.pathProfile,
    };
    context.go(loc);
  }

  PreferredSizeWidget _appBar(AppLocalizations l10n, ThemeData theme) {
    if (_index == 0) {
      return AppBar(
        toolbarHeight: 68,
        title: PostalPostmarkHeader(
          child: Semantics(
            label: l10n.appTitle,
            hint: l10n.appTagline,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.appTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.appTagline,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 15,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return AppBar(title: Text(_index == 1 ? l10n.tabMailbox : l10n.tabProfile));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: _appBar(l10n, theme),
      body: IndexedStack(
        index: _index,
        children: const [
          PostOfficeHomePage(key: ValueKey('post-office')),
          MailboxPage(key: ValueKey('mailbox')),
          ProfilePage(key: ValueKey('profile')),
        ],
      ),
      bottomNavigationBar: Semantics(
        label: l10n.a11yNavBar,
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _goBranch,
          destinations: [
            NavigationDestination(
              icon: Icon(
                Icons.mark_email_unread_outlined,
                semanticLabel: l10n.a11yTabPostWall,
              ),
              selectedIcon: Icon(
                Icons.mark_email_unread,
                semanticLabel: l10n.a11yTabPostWall,
              ),
              label: l10n.tabPostWall,
            ),
            NavigationDestination(
              icon: Icon(
                Icons.local_post_office_outlined,
                semanticLabel: l10n.a11yTabMailbox,
              ),
              selectedIcon: Icon(
                Icons.local_post_office,
                semanticLabel: l10n.a11yTabMailbox,
              ),
              label: l10n.tabMailbox,
            ),
            NavigationDestination(
              icon: Icon(
                Icons.collections_bookmark_outlined,
                semanticLabel: l10n.a11yTabProfile,
              ),
              selectedIcon: Icon(
                Icons.collections_bookmark,
                semanticLabel: l10n.a11yTabProfile,
              ),
              label: l10n.tabProfile,
            ),
          ],
        ),
      ),
    );
  }
}
