import 'package:flutter/material.dart';

import '../../app/theme/postal_tokens.dart';
import '../../l10n/app_localizations.dart';

/// 寄信成功后的投递动画遮罩（平邮/挂号发出）。
Future<void> showDeliverySentOverlay(
  BuildContext context, {
  String? destinationLabel,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: PostalTokens.inkNavy.withValues(alpha: 0.42),
    pageBuilder: (ctx, _, __) {
      return _DeliverySentOverlay(
        destinationLabel: destinationLabel,
        onDone: () => Navigator.of(ctx).pop(),
      );
    },
  );
}

class _DeliverySentOverlay extends StatefulWidget {
  const _DeliverySentOverlay({required this.onDone, this.destinationLabel});

  final VoidCallback onDone;
  final String? destinationLabel;

  @override
  State<_DeliverySentOverlay> createState() => _DeliverySentOverlayState();
}

class _DeliverySentOverlayState extends State<_DeliverySentOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
    Future<void>.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: Colors.transparent,
      child: Center(
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(0, -1.2),
          ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInCubic)),
          child: FadeTransition(
            opacity: Tween<double>(begin: 1, end: 0.2).animate(_ctrl),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 28),
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
              decoration: BoxDecoration(
                color: PostalTokens.paperCard,
                borderRadius: PostalTokens.shapeMd,
                border: Border.all(color: PostalTokens.perforationLine),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_shipping_outlined,
                    size: 56,
                    color: PostalTokens.postboxGreen,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    l10n.ritualDeliverySent,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (widget.destinationLabel != null &&
                      widget.destinationLabel!.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.destinationLabel!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: PostalTokens.inkSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
