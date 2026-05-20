import 'package:flutter/material.dart';

import '../../app/theme/postal_tokens.dart';

/// 注册向导共用壳：顶栏进度、大标题、底部圆形「下一步」。
class RegisterWizardScaffold extends StatelessWidget {
  const RegisterWizardScaffold({
    super.key,
    required this.stepIndex,
    required this.stepCount,
    required this.title,
    required this.subtitle,
    required this.onBack,
    required this.onNext,
    required this.child,
    this.footerHint,
    this.nextEnabled = true,
    this.nextBusy = false,
    this.isLastStep = false,
    this.nextLabel,
  });

  final int stepIndex;
  final int stepCount;
  final String title;
  final String subtitle;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final Widget child;
  final String? footerHint;
  final bool nextEnabled;
  final bool nextBusy;
  final bool isLastStep;
  final String? nextLabel;

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
            backgroundColor: PostalTokens.perforationLine.withValues(alpha: 0.45),
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
              Icon(Icons.info_outline_rounded, size: 18, color: PostalTokens.inkTertiary),
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
        Align(
          alignment: Alignment.centerRight,
          child: _WizardNextFab(
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

class _WizardNextFab extends StatelessWidget {
  const _WizardNextFab({
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
        color: enabled ? PostalTokens.postboxGreen : PostalTokens.perforationLine,
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

/// 性别/选项类大卡片（单选）。
class RegisterWizardChoiceTile extends StatelessWidget {
  const RegisterWizardChoiceTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected
          ? PostalTokens.paperEnvelope
          : PostalTokens.paperCard.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
            children: [
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: PostalTokens.inkNavy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected ? PostalTokens.postboxGreen : PostalTokens.inkTertiary,
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
