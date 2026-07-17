// ignore_for_file: sort_child_properties_last

import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../app/theme/postal_tokens.dart';
import '../../core/api/api_exception.dart';
import '../../core/models/domain_models.dart';
import '../../core/models/letter_peer_label.dart';
import '../../core/session/app_session.dart';
import '../../widgets/letter/letter_document.dart';
import '../../widgets/letter/letter_paper.dart';
import '../../widgets/postal/postal.dart';
import '../compose/compose_intent.dart';
import '../relation/relation_display_label.dart';
import '../relation/relation_remote.dart';
import '../ritual/letter_open_ritual_overlay.dart';
import '../ritual/postmark_widget.dart';
import 'mailbox_providers.dart';
import 'mailbox_remote.dart';

/// Dio 拦截器将业务失败封装为 [DioException.error]；统一取出可读文案。
String? _postalApiUserMessage(Object error) {
  if (error is ApiBusinessException) return error.message;
  if (error is DioException && error.error is ApiBusinessException) {
    return (error.error as ApiBusinessException).message;
  }
  if (error is DioException) return error.message;
  return null;
}

class LetterDetailPage extends ConsumerStatefulWidget {
  const LetterDetailPage({
    super.key,
    required this.letterId,
    this.firstOpen = false,
  });
  final String letterId;
  final bool firstOpen;

  @override
  ConsumerState<LetterDetailPage> createState() => _LetterDetailPageState();
}

class _LetterDetailPageState extends ConsumerState<LetterDetailPage> {
  bool _acceptBusy = false;

  /// 发起笔友申请成功后立即置灰按钮。
  bool _requestSentLocally = false;
  bool _favoriteBusy = false;
  bool _favorited = false;
  bool _showOpenRitual = false;

  @override
  void initState() {
    super.initState();
    _showOpenRitual = widget.firstOpen;
  }

  @override
  void dispose() {
    ref.invalidate(mailboxReceivedProvider);
    ref.invalidate(mailboxSentProvider);
    super.dispose();
  }

  String _auditLabel(AppLocalizations l10n, int auditStatus) {
    return switch (auditStatus) {
      0 => l10n.letterAuditPending,
      2 => l10n.letterAuditRejected,
      _ => l10n.letterAuditApproved,
    };
  }

  Widget _statusChip(AppLocalizations l10n, MailboxLetter letter) {
    return switch (letter.status) {
      // MATCHED：邮局已配对，仍属在途语义，单独标签便于用户辨认。
      LetterStatus.matched => PostalStatusChip.delivering(
        label: l10n.letterStatusMatched,
      ),
      LetterStatus.pending ||
      LetterStatus.delivering => PostalStatusChip.delivering(),
      LetterStatus.registered => PostalStatusChip.registered(
        label: 'Registered',
      ),
      LetterStatus.delivered =>
        letter.type == LetterType.registered
            ? PostalStatusChip.registered(label: 'Registered')
            : PostalStatusChip.delivered(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final letterAsync = ref.watch(letterDetailProvider(widget.letterId));
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.letterDetailTitle),
        actions: [
          letterAsync.maybeWhen(
            data: (letter) {
              if (letter == null) return const SizedBox.shrink();
              final starred = _favorited || letter.favorited;
              return IconButton(
                tooltip: starred ? l10n.letterUnfavorite : l10n.letterFavorite,
                onPressed: _favoriteBusy
                    ? null
                    : () => _toggleFavorite(letter, starred),
                icon: Icon(
                  starred ? Icons.star_rounded : Icons.star_outline_rounded,
                ),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            letterAsync.when(
              loading: () =>
                  const PostalSkeletonList(itemCount: 1, itemHeight: 260),
              error: (e, _) => PostalEmptyState(
                title: 'Unable to load letter',
                subtitle: '$e',
                tone: PostalEmptyTone.error,
              ),
              data: (letter) {
                if (letter == null) {
                  return const PostalEmptyState(
                    title: 'Letter not found',
                    subtitle: 'This letter may have expired.',
                  );
                }
                if (!_favorited && letter.favorited) {
                  _favorited = true;
                }
                final isDelivering =
                    letter.status == LetterStatus.delivering ||
                    letter.status == LetterStatus.pending ||
                    letter.status == LetterStatus.matched;
                final isRegistered = letter.status == LetterStatus.registered;
                final eta = letter.expectedArrivalAt ?? letter.deliveryAt;
                final relationState = letter.relationDisplayState;
                final isPenpal = relationState == RelationDisplayState.penpal;
                final requestPending =
                    relationState == RelationDisplayState.pendingOut ||
                    _requestSentLocally;
                final showAddPenpalSlot =
                    !letter.outgoing &&
                    letter.status == LetterStatus.delivered &&
                    letter.canAddPenpal &&
                    !isPenpal &&
                    !requestPending;
                final canReply =
                    !letter.outgoing &&
                    letter.status == LetterStatus.delivered &&
                    letter.peer.id.isNotEmpty;
                final peerTitle = letterPeerDisplayTitle(
                  l10n: l10n,
                  peer: letter.peer,
                  mode: letter.mode,
                );

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                  children: [
                    PostmarkWidget(
                      fromCountryName:
                          letter.fromCountryName ??
                          (letter.outgoing
                              ? ref.read(appSessionProvider).user.countryName
                              : letter.peer.countryName),
                      toCountryName:
                          letter.toCountryName ??
                          (letter.outgoing
                              ? letter.peer.countryName
                              : ref.read(appSessionProvider).user.countryName),
                      sentAt: letter.sentAt,
                      label: letter.postmarkLabel,
                    ),
                    const SizedBox(height: 12),
                    PostalCardEnvelope(
                      backgroundColor: PostalTokens.paperEnvelope,
                      header: Row(
                        children: [
                          isUnresolvedLetterPeer(letter.peer)
                              ? _RecommendingAvatar(size: 40)
                              : PostalAvatar(
                                  name: peerTitle,
                                  size: 40,
                                  imageUrl: letter.peer.avatarUrl,
                                ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              peerTitle,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          _statusChip(l10n, letter),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (letter.auditStatus != 1)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                l10n.letterAuditLine(
                                  _auditLabel(l10n, letter.auditStatus),
                                ),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: PostalTokens.stampVermilion,
                                    ),
                              ),
                            ),
                          if (relationState != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                relationDisplayLabel(l10n, relationState),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: PostalTokens.postboxGreen,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                          if (isRegistered)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 6,
                                bottom: 10,
                              ),
                              child: Text(
                                'Registered mail: filing complete. It will show as delivered in a moment.',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: PostalTokens.inkSecondary,
                                    ),
                              ),
                            )
                          else
                            const SizedBox(height: 10),
                          LetterPaper(
                            mode: LetterPaperMode.read,
                            document: LetterDocument(
                              body: letter.body,
                              skinId:
                                  letter.skinId ?? LetterDocument.defaultSkinId,
                              fontId:
                                  letter.fontId ?? LetterDocument.defaultFontId,
                              fontSizeTier: FontSizeTier.fromApi(
                                letter.fontSizeTier,
                              ),
                            ),
                            minHeight: 160,
                            readOnlyOverlay: letter.contentHidden
                                ? ClipRRect(
                                    borderRadius: PostalTokens.shapeLg,
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 14,
                                        sigmaY: 14,
                                      ),
                                      child: Container(
                                        alignment: Alignment.center,
                                        color: PostalTokens.kraftBrownMuted
                                            .withValues(alpha: 0.42),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        child: Text(
                                          l10n.letterContentHiddenHint,
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                height: 1.45,
                                                color:
                                                    PostalTokens.inkSecondary,
                                              ),
                                        ),
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Sent at ${DateFormat("MM-dd HH:mm").format(letter.sentAt)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          if (eta != null)
                            Text(
                              '${isDelivering
                                  ? l10n.letterEtaLabel
                                  : isRegistered
                                  ? l10n.letterEtaLabel
                                  : l10n.letterDeliveredLabel} ${DateFormat("MM-dd HH:mm").format(eta)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                    if (showAddPenpalSlot) ...[
                      const SizedBox(height: 14),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 320),
                        child: PostalButton(
                          key: ValueKey('add_penpal_${letter.id}'),
                          label: l10n.relationAddPenpal,
                          busy: _acceptBusy,
                          onPressed: _acceptBusy
                              ? null
                              : () async {
                                  setState(() => _acceptBusy = true);
                                  try {
                                    await ref
                                        .read(relationRemoteProvider)
                                        .createPenpalRequest(
                                          peerUserId: letter.peer.id,
                                          sourceLetterId: letter.id,
                                        );
                                    if (!context.mounted) return;
                                    setState(() => _requestSentLocally = true);
                                    PostalSnack.show(
                                      context,
                                      l10n.relationAddPenpalSuccess,
                                      tone: PostalSnackTone.success,
                                    );
                                    ref.invalidate(
                                      letterDetailProvider(widget.letterId),
                                    );
                                    ref.invalidate(
                                      relationWithProvider(letter.peer.id),
                                    );
                                    ref.invalidate(mailboxReceivedProvider);
                                    ref.invalidate(mailboxSentProvider);
                                  } catch (e) {
                                    final msg = _postalApiUserMessage(e);
                                    if (context.mounted && msg != null) {
                                      PostalSnack.show(
                                        context,
                                        msg,
                                        tone: PostalSnackTone.error,
                                      );
                                    }
                                  } finally {
                                    if (context.mounted) {
                                      setState(() => _acceptBusy = false);
                                    }
                                  }
                                },
                        ),
                      ),
                    ] else if (requestPending) ...[
                      const SizedBox(height: 14),
                      PostalButton(
                        label: l10n.letterAcceptContactDone,
                        variant: PostalButtonVariant.secondary,
                        onPressed: null,
                      ),
                    ],
                    const SizedBox(height: 16),
                    // 仅收件人且已送达：入口进写信桌回信；发件人 / 在途一律不展示回信区。
                    if (canReply) ...[
                      Text(
                        l10n.letterReplyHint,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: PostalTokens.inkSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      PostalButton(
                        label: l10n.letterReplyCta,
                        icon: Icons.reply_outlined,
                        onPressed: () {
                          context.push(
                            '/compose',
                            extra: ComposeIntent(
                              kind: ComposeKind.penPalMail,
                              peerId: letter.peer.id,
                              peerNickname: letter.peer.nickname,
                              parentLetterId: letter.id,
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                );
              },
            ),
            if (_showOpenRitual)
              LetterOpenRitualOverlay(
                onComplete: () => setState(() => _showOpenRitual = false),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleFavorite(MailboxLetter letter, bool starred) async {
    setState(() => _favoriteBusy = true);
    try {
      final repo = ref.read(mailboxRemoteRepositoryProvider);
      if (starred) {
        await repo.unfavoriteLetter(letter.id);
        setState(() => _favorited = false);
      } else {
        await repo.favoriteLetter(letter.id);
        setState(() => _favorited = true);
      }
      ref.invalidate(letterFavoritesProvider);
    } catch (e) {
      final msg = _postalApiUserMessage(e);
      if (mounted && msg != null) {
        PostalSnack.show(context, msg, tone: PostalSnackTone.error);
      }
    } finally {
      if (mounted) setState(() => _favoriteBusy = false);
    }
  }
}

/// 未配对收件人头像：信封图标，避免显示「?」字母。
class _RecommendingAvatar extends StatelessWidget {
  const _RecommendingAvatar({this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: PostalTokens.kraftBrown, width: 1.4),
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              PostalTokens.kraftBrownMuted.withValues(alpha: 0.55),
              PostalTokens.paperEnvelope,
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.markunread_mailbox_outlined,
          size: size * 0.48,
          color: PostalTokens.postboxGreen,
        ),
      ),
    );
  }
}
