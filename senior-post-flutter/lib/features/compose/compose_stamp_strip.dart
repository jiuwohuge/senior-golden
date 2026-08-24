import 'package:flutter/material.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../app/theme/postal_tokens.dart';
import '../../core/models/letter_topic_option.dart';

/// 邮票条展示用短词：信纸上沿用全称会挤成 3 枚半。
String composeStampShortLabel(AppLocalizations l10n, LetterTopicOption topic) {
  return switch (topic.code) {
    'heart_talk' => l10n.composeStampShortHeartTalk,
    'life_share' => l10n.composeStampShortLifeShare,
    'interest_exchange' => l10n.composeStampShortInterest,
    'life_puzzle' => l10n.composeStampShortPuzzle,
    'just_chat' => l10n.composeStampShortChat,
    _ => topic.title,
  };
}

/// 书桌上的齿孔邮票条：贴在信纸外，单选可揭，窄屏横滑。
class ComposeStampStrip extends StatelessWidget {
  const ComposeStampStrip({
    super.key,
    required this.topics,
    required this.selectedId,
    required this.onSelected,
    required this.compact,
    required this.compactLabel,
    required this.onExpandCompact,
    this.labelOf,
  });

  final List<LetterTopicOption> topics;
  final int? selectedId;
  final ValueChanged<int?> onSelected;
  final bool compact;
  final String compactLabel;
  final VoidCallback onExpandCompact;
  final String Function(LetterTopicOption topic)? labelOf;

  String _label(LetterTopicOption topic) =>
      labelOf?.call(topic) ?? topic.title;

  @override
  Widget build(BuildContext context) {
    if (topics.isEmpty) {
      return const SizedBox.shrink();
    }
    if (compact) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onExpandCompact,
          borderRadius: PostalTokens.shapeSm,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
              child: Row(
                children: [
                  Icon(
                    Icons.local_offer_outlined,
                    size: 18,
                    color: selectedId == null
                        ? PostalTokens.kraftBrown
                        : PostalTokens.stampVermilion,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      compactLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: PostalTokens.inkNavy,
                      ),
                    ),
                  ),
                  const Icon(Icons.expand_more, size: 22),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: topics.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final topic = topics[index];
          final selected = topic.id == selectedId;
          return _PerforatedStamp(
            title: _label(topic),
            selected: selected,
            onTap: () => onSelected(selected ? null : topic.id),
          );
        },
      ),
    );
  }
}

class _PerforatedStamp extends StatelessWidget {
  const _PerforatedStamp({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        selected ? PostalTokens.stampVermilion : PostalTokens.kraftBrown;
    final fill = selected
        ? PostalTokens.stampVermilionMuted
        : PostalTokens.paperEnvelope.withValues(alpha: 0.92);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(3),
        child: CustomPaint(
          painter: _StampPerforationPainter(
            borderColor: borderColor,
            fillColor: fill,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Center(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? PostalTokens.stampVermilion
                        : PostalTokens.inkNavy,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 齿孔小票描边，避免 Material FilterChip 默认样式。
class _StampPerforationPainter extends CustomPainter {
  _StampPerforationPainter({
    required this.borderColor,
    required this.fillColor,
  });

  final Color borderColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(3),
    );
    canvas.drawRRect(rect, Paint()..color = fillColor);
    final border = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    _drawDashedRRect(canvas, rect, border, 2.8, 2.2);
  }

  void _drawDashedRRect(
    Canvas canvas,
    RRect rect,
    Paint paint,
    double dash,
    double gap,
  ) {
    final path = Path()..addRRect(rect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      var draw = true;
      while (distance < metric.length) {
        final next = distance + (draw ? dash : gap);
        if (draw) {
          canvas.drawPath(
            metric.extractPath(distance, next.clamp(0, metric.length)),
            paint,
          );
        }
        distance = next;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _StampPerforationPainter oldDelegate) {
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.fillColor != fillColor;
  }
}
