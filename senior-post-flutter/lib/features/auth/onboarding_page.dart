import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../widgets/postal/postal.dart';
import 'login_routes.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pages = [
      _OnboardData(
        icon: Icons.public_outlined,
        title: l10n.onboardTitle1,
        body: l10n.onboardBody1,
      ),
      _OnboardData(
        icon: Icons.mail_outline,
        title: l10n.onboardTitle2,
        body: l10n.onboardBody2,
      ),
      _OnboardData(
        icon: Icons.shield_outlined,
        title: l10n.onboardTitle3,
        body: l10n.onboardBody3,
      ),
    ];
    return Scaffold(
      body: PaperTextureBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              22 + MediaQuery.viewPaddingOf(context).bottom,
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: PostalButton(
                    label: l10n.onboardSkip,
                    onPressed: () => context.go(LoginRoutes.login),
                    variant: PostalButtonVariant.ghost,
                    expand: false,
                    minHeight: 38,
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: pages.length,
                    onPageChanged: (v) => setState(() => _index = v),
                    itemBuilder: (_, i) {
                      final p = pages[i];
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          PostmarkRing(
                            size: 88,
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                            year: '26',
                          ),
                          const SizedBox(height: 16),
                          Icon(p.icon, size: 58, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(height: 20),
                          Text(
                            p.title,
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              p.body,
                              style: Theme.of(context).textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    pages.length,
                    (i) => Container(
                      width: i == _index ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: i == _index
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                PostalButton(
                  label: _index == pages.length - 1 ? l10n.onboardDone : l10n.onboardNext,
                  onPressed: () async {
                    if (_index == pages.length - 1) {
                      context.go(LoginRoutes.login);
                      return;
                    }
                    await _controller.nextPage(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardData {
  _OnboardData({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;
}
