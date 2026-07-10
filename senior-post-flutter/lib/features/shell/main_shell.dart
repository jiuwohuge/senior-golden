import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';
import 'package:senior_post_flutter/widgets/postal_decorations.dart';

import '../../app/theme/postal_tokens.dart';
import '../post_office/post_office_home_page.dart';
import '../directory/directory_page.dart';
import '../mailbox/im_unread_providers.dart';
import '../mailbox/mailbox_page.dart';
import '../profile/profile_page.dart';

/// Main bottom tabs: Post Office / Pen Pals / Mailbox / Me (4.0).
abstract final class MainShellRoute {
  static const pathPostOffice = '/';
  static const pathPenPals = '/penpals';
  static const pathMailbox = '/mailbox';
  static const pathProfile = '/profile';
}

/// Main shell for the 4.0 slow-mail post office experience.
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
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
      0 => MainShellRoute.pathPostOffice,
      1 => MainShellRoute.pathPenPals,
      2 => MainShellRoute.pathMailbox,
      _ => MainShellRoute.pathProfile,
    };
    context.go(loc);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final imUnreadTotal = foldImC2cUnreadTotal(ref.watch(imC2cUnreadProvider));

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
          PostOfficeHomePage(key: ValueKey('post-office')),
          DirectoryPage(key: ValueKey('penpals')),
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
                Icons.diversity_3_outlined,
                semanticLabel: l10n.a11yTabDirectory,
              ),
              selectedIcon: Icon(
                Icons.diversity_3,
                semanticLabel: l10n.a11yTabDirectory,
              ),
              label: l10n.tabDirectory,
            ),
            NavigationDestination(
              icon: _NavIconWithDot(
                showDot: imUnreadTotal > 0,
                icon: Icons.local_post_office_outlined,
                semanticLabel: l10n.a11yTabMailbox,
              ),
              selectedIcon: _NavIconWithDot(
                showDot: imUnreadTotal > 0,
                icon: Icons.local_post_office,
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

class _NavIconWithDot extends StatelessWidget {
  const _NavIconWithDot({
    required this.showDot,
    required this.icon,
    required this.semanticLabel,
  });

  final bool showDot;
  final IconData icon;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final ic = Icon(icon, semanticLabel: semanticLabel);
    if (!showDot) {
      return ic;
    }
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ic,
        Positioned(
          right: -1,
          top: -2,
          child: Container(
            width: 11,
            height: 11,
            decoration: BoxDecoration(
              color: PostalTokens.stampVermilion,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.surface,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
