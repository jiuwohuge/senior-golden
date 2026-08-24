import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../app/theme/postal_tokens.dart';
import '../../core/api/api_exception.dart';
import '../../core/models/domain_models.dart';
import '../../widgets/postal/postal.dart';
import '../directory/directory_providers.dart';
import '../relation/relation_remote.dart';

class PostOfficeRelationMessagesPage extends ConsumerWidget {
  const PostOfficeRelationMessagesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(postOfficeRelationMessagesProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.postOfficeRelationMessagesTitle),
        backgroundColor: PostalTokens.postboxGreen,
        foregroundColor: Colors.white,
      ),
      body: async.when(
        loading: () => const PostalSkeletonList(itemCount: 4, itemHeight: 96),
        error: (e, _) => PostalEmptyState(
          title: l10n.commonLoadFailed,
          subtitle: '$e',
          tone: PostalEmptyTone.error,
          actionLabel: l10n.commonRetry,
          onAction: () => ref.invalidate(postOfficeRelationMessagesProvider),
        ),
        data: (rows) {
          if (rows.isEmpty) {
            return PostalEmptyState(
              title: l10n.postOfficeRelationMessagesEmpty,
              subtitle: l10n.postOfficeRelationMessagesEmptyHint,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: rows.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _RelationMessageTile(message: rows[i]),
          );
        },
      ),
    );
  }
}

class _RelationMessageTile extends ConsumerStatefulWidget {
  const _RelationMessageTile({required this.message});

  final PostOfficeRelationMessage message;

  @override
  ConsumerState<_RelationMessageTile> createState() =>
      _RelationMessageTileState();
}

class _RelationMessageTileState extends ConsumerState<_RelationMessageTile> {
  bool _busy = false;

  Future<void> _accept() async {
    final id = widget.message.requestId;
    if (id == null || _busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(relationRemoteProvider).acceptPenpalRequest(id);
      ref.invalidate(postOfficeRelationMessagesProvider);
      ref.invalidate(myPenpalsProvider);
      if (mounted) {
        PostalSnack.show(
          context,
          AppLocalizations.of(context)!.penpalAcceptSuccess,
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

  Future<void> _ignore() async {
    final id = widget.message.requestId;
    if (id == null || _busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(relationRemoteProvider).ignorePenpalRequest(id);
      ref.invalidate(postOfficeRelationMessagesProvider);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _addPenpal() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(relationRemoteProvider)
          .createPenpalRequest(peerUserId: widget.message.peer.id);
      ref.invalidate(postOfficeRelationMessagesProvider);
      if (mounted) {
        PostalSnack.show(
          context,
          AppLocalizations.of(context)!.penpalRequestSent,
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
    final m = widget.message;
    final isRequest = m.messageType == 1;
    return PostalCardEnvelope(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(m.peer.nickname, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(l10n.penpalExchangeCount(m.letterCount)),
          const SizedBox(height: 12),
          if (isRequest) ...[
            Row(
              children: [
                Expanded(
                  child: PostalButton(
                    label: l10n.penpalAccept,
                    busy: _busy,
                    onPressed: _busy ? null : _accept,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PostalButton(
                    label: l10n.penpalIgnore,
                    variant: PostalButtonVariant.secondary,
                    busy: _busy,
                    onPressed: _busy ? null : _ignore,
                  ),
                ),
              ],
            ),
          ] else if (m.canAddPenpal)
            PostalButton(
              label: l10n.relationAddPenpal,
              busy: _busy,
              onPressed: _busy ? null : _addPenpal,
            ),
        ],
      ),
    );
  }
}
