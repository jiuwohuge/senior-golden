import 'package:flutter/material.dart';

import '../../app/theme/postal_tokens.dart';

/// One-screen-at-a-time container for the unified compose flow.
class ComposeStepScaffold extends StatelessWidget {
  const ComposeStepScaffold({
    super.key,
    required this.stepIndex,
    required this.stepCount,
    required this.title,
    required this.subtitle,
    required this.onBack,
    required this.child,
    this.footerHint,
    this.onNext,
    this.nextEnabled = true,
    this.nextBusy = false,
    this.isLastStep = false,
    this.nextLabel,
    this.bottomAction,
  });

  final int stepIndex;
  final int stepCount;
  final String title;
  final String subtitle;
  final VoidCallback? onBack;
  final Widget child;
  final String? footerHint;
  final VoidCallback? onNext;
  final bool nextEnabled;
  final bool nextBusy;
  final bool isLastStep;
  final String? nextLabel;

  /// When set, replaces the default circular next FAB (e.g. seal slider).
  final Widget? bottomAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = stepCount > 0 ? (stepIndex + 1) / stepCount : 0.0;
    final bottom = MediaQuery.viewPaddingOf(context).bottom;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress.clamp(0.05, 1.0),
            minHeight: 4,
            backgroundColor: PostalTokens.perforationLine.withValues(
              alpha: 0.45,
            ),
            color: PostalTokens.postboxGreen,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              color: PostalTokens.inkNavy,
              onPressed: onBack,
            ),
            Expanded(
              child: Text(
                '${stepIndex + 1} / $stepCount',
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: PostalTokens.inkTertiary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: PostalTokens.inkNavy,
            fontWeight: FontWeight.w800,
            height: 1.15,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: PostalTokens.inkSecondary,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 32),
        Expanded(child: child),
        if (footerHint != null) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: PostalTokens.inkTertiary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  footerHint!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: PostalTokens.inkTertiary,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        if (bottomAction != null)
          bottomAction!
        else
          Align(
            alignment: Alignment.centerRight,
            child: _ComposeNextFab(
              enabled: nextEnabled && !nextBusy,
              busy: nextBusy,
              isLast: isLastStep,
              label: nextLabel,
              onPressed: onNext,
            ),
          ),
        SizedBox(height: 12 + bottom),
      ],
    );
  }
}

class ComposeChoiceTile extends StatelessWidget {
  const ComposeChoiceTile({
    super.key,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected
          ? PostalTokens.paperEnvelope
          : PostalTokens.paperCard.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? PostalTokens.postboxGreen
                  : PostalTokens.perforationLine.withValues(alpha: 0.9),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: PostalTokens.postboxGreen.withValues(alpha: 0.1),
                  borderRadius: PostalTokens.shapeSm,
                ),
                child: Icon(icon, color: PostalTokens.postboxGreen),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: PostalTokens.inkNavy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: PostalTokens.inkSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected
                    ? PostalTokens.postboxGreen
                    : PostalTokens.inkTertiary,
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComposeNextFab extends StatelessWidget {
  const _ComposeNextFab({
    required this.enabled,
    required this.busy,
    required this.isLast,
    required this.onPressed,
    this.label,
  });

  final bool enabled;
  final bool busy;
  final bool isLast;
  final VoidCallback? onPressed;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: enabled
            ? PostalTokens.postboxGreen
            : PostalTokens.perforationLine,
        elevation: enabled ? 4 : 0,
        shadowColor: PostalTokens.inkNavy.withValues(alpha: 0.2),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: enabled && !busy ? onPressed : null,
          child: SizedBox(
            width: 56,
            height: 56,
            child: busy
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    isLast ? Icons.check_rounded : Icons.chevron_right_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
          ),
        ),
      ),
    );
  }
}
