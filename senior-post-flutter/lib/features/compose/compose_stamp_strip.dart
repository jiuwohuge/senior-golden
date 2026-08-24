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

/// 写信主题快捷栏：轻量单选胶囊，窄屏横滑。
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

  String _label(LetterTopicOption topic) => labelOf?.call(topic) ?? topic.title;

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
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: topics.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final topic = topics[index];
          final selected = topic.id == selectedId;
          return _TopicPill(
            title: _label(topic),
            selected: selected,
            onTap: () => onSelected(selected ? null : topic.id),
          );
        },
      ),
    );
  }
}

class _TopicPill extends StatelessWidget {
  const _TopicPill({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? PostalTokens.postboxGreen : PostalTokens.paperEnvelope,
      borderRadius: PostalTokens.shapeSm,
      child: InkWell(
        onTap: onTap,
        borderRadius: PostalTokens.shapeSm,
        child: AnimatedContainer(
          duration: PostalTokens.durationFast,
          constraints: const BoxConstraints(minHeight: 48, minWidth: 52),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: PostalTokens.shapeSm,
            border: Border.all(
              color: selected
                  ? PostalTokens.postboxGreen
                  : PostalTokens.perforationLine,
              width: selected ? 1.6 : 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                const Icon(Icons.check, size: 17, color: Colors.white),
                const SizedBox(width: 6),
              ],
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.1,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: selected ? Colors.white : PostalTokens.inkNavy,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
