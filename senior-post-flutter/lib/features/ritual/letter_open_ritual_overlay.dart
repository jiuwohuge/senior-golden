import 'package:flutter/material.dart';

import '../../app/theme/postal_tokens.dart';
import '../../l10n/app_localizations.dart';

/// 首次读信拆封仪式：全屏遮罩 + 信封展开动画。
class LetterOpenRitualOverlay extends StatefulWidget {
  const LetterOpenRitualOverlay({
    super.key,
    required this.onComplete,
    this.busy = false,
  });

  final VoidCallback onComplete;
  final bool busy;

  @override
  State<LetterOpenRitualOverlay> createState() =>
      _LetterOpenRitualOverlayState();
}

class _LetterOpenRitualOverlayState extends State<LetterOpenRitualOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    if (widget.busy) return;
    await _ctrl.forward();
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: PostalTokens.inkNavy.withValues(alpha: 0.55),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              ScaleTransition(
                scale: Tween<double>(begin: 1, end: 1.1).animate(
                  CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
                ),
                child: Icon(
                  Icons.mail_outline,
                  size: 132,
                  color: PostalTokens.paperCream.withValues(alpha: 0.95),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                l10n.ritualOpenLetter,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: widget.busy ? null : _open,
                  child: widget.busy
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.timeLetterOpenRitual),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
