import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';
import 'package:senior_post_flutter/widgets/postal_decorations.dart';

import '../directory/directory_page.dart';
import '../mailbox/mailbox_page.dart';
import '../post_wall/post_wall_page.dart';
import '../profile/profile_page.dart';

/// 底部四 Tab 与路由路径（与需求文档 Tab 结构一致）。
abstract final class MainShellRoute {
  static const pathPostWall = '/';
  static const pathDirectory = '/directory';
  static const pathMailbox = '/mailbox';
  static const pathProfile = '/profile';
}

/// 主框架：Post Wall / Directory / Post Box / My Post。
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
    _index = widget.initialIndex.clamp(0, 3);
  }

  void _goBranch(int index) {
    setState(() => _index = index);
    if (!mounted) return;
    final loc = switch (index) {
      0 => MainShellRoute.pathPostWall,
      1 => MainShellRoute.pathDirectory,
      2 => MainShellRoute.pathMailbox,
      _ => MainShellRoute.pathProfile,
    };
    context.go(loc);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 76,
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
                    fontSize: 16,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: IndexedStack(
        index: _index,
        children: const [
          PostWallPage(key: ValueKey('wall')),
          DirectoryPage(key: ValueKey('directory')),
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
                Icons.collections_bookmark_outlined,
                semanticLabel: l10n.a11yTabPostWall,
              ),
              selectedIcon: Icon(
                Icons.collections_bookmark,
                semanticLabel: l10n.a11yTabPostWall,
              ),
              label: l10n.tabPostWall,
            ),
            NavigationDestination(
              icon: Icon(
                Icons.grid_view_outlined,
                semanticLabel: l10n.a11yTabDirectory,
              ),
              selectedIcon: Icon(
                Icons.grid_view,
                semanticLabel: l10n.a11yTabDirectory,
              ),
              label: l10n.tabDirectory,
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
                Icons.person_outline,
                semanticLabel: l10n.a11yTabProfile,
              ),
              selectedIcon: Icon(
                Icons.person,
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
