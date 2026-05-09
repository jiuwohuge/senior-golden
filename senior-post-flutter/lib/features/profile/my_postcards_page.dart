import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../app/theme/postal_tokens.dart';
import '../../core/models/domain_models.dart';
import '../../widgets/postal/postal.dart';
import '../post_wall/post_providers.dart';

class MyPostcardsPage extends ConsumerWidget {
  const MyPostcardsPage({super.key});

  static String _auditLine(AppLocalizations l10n, WallPost p) {
    final rs = p.reviewStatus;
    final ps = p.postStatus;
    final parts = <String>[];
    if (rs == 0) {
      parts.add(l10n.postcardReviewPendingBadge);
    } else if (rs == 2) {
      parts.add(l10n.postcardReviewRejectedBadge);
    } else if (rs == 1) {
      parts.add(l10n.postcardReviewApprovedBadge);
    }
    if (ps == 2) {
      parts.add(l10n.postcardPostHiddenBadge);
    } else if (ps == 3) {
      parts.add(l10n.postcardPostRemovedBadge);
    }
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(myPostcardsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileMyPostcards)),
      body: SafeArea(
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => PostalEmptyState(
            title: l10n.myPostcardsLoadFailedTitle,
            subtitle: '$e',
            tone: PostalEmptyTone.error,
            actionLabel: l10n.commonRetry,
            onAction: () => ref.invalidate(myPostcardsProvider),
          ),
          data: (items) {
            if (items.isEmpty) {
              return PostalEmptyState(
                title: l10n.myPostcardsEmptyTitle,
                subtitle: l10n.myPostcardsEmptySubtitle,
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(myPostcardsProvider);
                await ref.read(myPostcardsProvider.future);
              },
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final p = items[i];
                  final thumb = p.resolvedImageUrls.isNotEmpty ? p.resolvedImageUrls.first : null;
                  final excerpt = p.content.length > 120 ? '${p.content.substring(0, 120)}…' : p.content;
                  return PostalCardEnvelope(
                    onTap: () => context.push('/post/${p.id}'),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (thumb != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 72,
                              height: 72,
                              child: PostalOssNetworkImage(imageUrl: thumb, fit: BoxFit.cover),
                            ),
                          )
                        else
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: PostalTokens.kraftBrown.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: PostalTokens.kraftBrown.withValues(alpha: 0.35)),
                            ),
                            child: Icon(Icons.article_outlined, color: PostalTokens.inkSecondary),
                          ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _auditLine(l10n, p),
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      color: PostalTokens.stampVermilion,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                excerpt,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                DateFormat('yyyy-MM-dd HH:mm').format(p.createdAt),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: PostalTokens.inkTertiary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: PostalTokens.inkTertiary),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
