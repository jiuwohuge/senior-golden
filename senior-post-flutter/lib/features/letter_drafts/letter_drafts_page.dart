import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../core/api/api_exception.dart';
import '../../core/models/domain_models.dart';
import '../../widgets/postal/postal.dart';
import '../mailbox/mailbox_providers.dart';
import 'letter_drafts_remote.dart';

/// 普通信件草稿列表：查看、发送或删除。
class LetterDraftsPage extends ConsumerWidget {
  const LetterDraftsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(letterDraftsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.letterDraftsTitle)),
      body: SafeArea(
        child: async.when(
          loading: () => const PostalSkeletonList(itemCount: 4, itemHeight: 88),
          error: (e, _) => PostalEmptyState(
            title: l10n.commonLoadFailed,
            subtitle: '$e',
            tone: PostalEmptyTone.error,
            actionLabel: l10n.commonRetry,
            onAction: () => ref.invalidate(letterDraftsProvider),
          ),
          data: (drafts) {
            if (drafts.isEmpty) {
              return PostalEmptyState(
                title: l10n.letterDraftsEmptyTitle,
                subtitle: l10n.letterDraftsEmptySubtitle,
                actionLabel: l10n.composeTitle,
                onAction: () => context.push('/compose'),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              itemCount: drafts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final draft = drafts[index];
                return _DraftCard(draft: draft);
              },
            );
          },
        ),
      ),
    );
  }
}

class _DraftCard extends ConsumerStatefulWidget {
  const _DraftCard({required this.draft});

  final LetterDraft draft;

  @override
  ConsumerState<_DraftCard> createState() => _DraftCardState();
}

class _DraftCardState extends ConsumerState<_DraftCard> {
  bool _busy = false;

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      await ref.read(letterDraftsRemoteProvider).sendDraft(widget.draft.id);
      ref.invalidate(letterDraftsProvider);
      ref.invalidate(mailboxLettersProvider);
      ref.invalidate(mailboxSentProvider);
      if (!mounted) return;
      PostalSnack.show(
        context,
        l10n.sendLetterSentSuccess,
        tone: PostalSnackTone.success,
      );
    } on ApiBusinessException catch (e) {
      if (mounted) {
        PostalSnack.show(context, e.message, tone: PostalSnackTone.error);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      await ref.read(letterDraftsRemoteProvider).deleteDraft(widget.draft.id);
      ref.invalidate(letterDraftsProvider);
      if (mounted) {
        PostalSnack.show(
          context,
          l10n.letterDraftsDeleted,
          tone: PostalSnackTone.success,
        );
      }
    } on ApiBusinessException catch (e) {
      if (mounted) {
        PostalSnack.show(context, e.message, tone: PostalSnackTone.error);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final draft = widget.draft;
    final preview = draft.content.trim().isEmpty
        ? l10n.letterDraftsNoContent
        : draft.content;
    final updated = draft.updatedAt;
    return PostalCardEnvelope(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${draft.mode}',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (updated != null) ...[
            const SizedBox(height: 4),
            Text(
              l10n.letterDraftsUpdated(
                DateFormat.yMMMd().add_Hm().format(updated),
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 8),
          Text(
            preview,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _busy ? null : _delete,
                  child: Text(l10n.letterDraftsDelete),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: _busy ? null : _send,
                  child: Text(l10n.letterDraftsSend),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
