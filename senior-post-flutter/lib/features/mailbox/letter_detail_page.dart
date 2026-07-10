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
import '../../core/session/app_session.dart';
import '../../widgets/postal/postal.dart';
import '../auth/auth_repository.dart';
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

/// 回信邮种：高对比选中态 + 副标题，避免主题 [ChoiceChip] 选中后字色不可读。
Widget _replyMailKindChip({
  required BuildContext context,
  required String title,
  required String subtitle,
  required bool selected,
  required VoidCallback onTap,
}) {
  final bg = selected ? PostalTokens.postboxGreen : PostalTokens.paperCard;
  final border = selected
      ? PostalTokens.postboxGreen
      : PostalTokens.perforationLine;
  final titleColor = selected ? Colors.white : PostalTokens.inkNavy;
  final subColor = selected
      ? Colors.white.withValues(alpha: 0.9)
      : PostalTokens.inkSecondary;

  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: PostalTokens.shapeSm,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: PostalTokens.shapeSm,
          border: Border.all(color: border, width: selected ? 2 : 1.2),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: PostalTokens.postboxGreen.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: titleColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (selected)
                  Icon(
                    Icons.check_circle_rounded,
                    size: 22,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: subColor,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class LetterDetailPage extends ConsumerStatefulWidget {
  const LetterDetailPage({super.key, required this.letterId});
  final String letterId;

  @override
  ConsumerState<LetterDetailPage> createState() => _LetterDetailPageState();
}

class _LetterDetailPageState extends ConsumerState<LetterDetailPage> {
  final _reply = TextEditingController();
  bool _acceptBusy = false;

  /// 接受成功后立即置灰按钮，不等待 friendship provider 二次请求。
  bool _acceptedLocally = false;
  bool _replyBusy = false;
  LetterType _replyType = LetterType.standard;

  @override
  void dispose() {
    ref.invalidate(postalInboxLettersProvider);
    _reply.dispose();
    super.dispose();
  }


  String _modeLabel(AppLocalizations l10n, LetterMode mode) {
    return switch (mode) {
      LetterMode.postOffice => l10n.letterModePostOffice,
      LetterMode.direct => l10n.letterModeDirect,
      LetterMode.selfTime => l10n.letterModeSelfTime,
    };
  }

  String _auditLabel(AppLocalizations l10n, int auditStatus) {
    return switch (auditStatus) {
      0 => l10n.letterAuditPending,
      2 => l10n.letterAuditRejected,
      _ => l10n.letterAuditApproved,
    };
  }

  Widget _statusChip(MailboxLetter letter) {
    return switch (letter.status) {
      LetterStatus.pending ||
      LetterStatus.matched ||
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
      appBar: AppBar(title: Text(l10n.letterDetailTitle)),
      body: SafeArea(
        child: letterAsync.when(
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
            final isDelivering =
                letter.status == LetterStatus.delivering ||
                letter.status == LetterStatus.pending ||
                letter.status == LetterStatus.matched;
            final isRegistered = letter.status == LetterStatus.registered;
            final eta = letter.expectedArrivalAt ?? letter.deliveryAt;
            final friendsAsync = ref.watch(
              friendshipActiveProvider(letter.peer.id),
            );
            final isFriend = friendsAsync.valueOrNull ?? false;
            final connected = isFriend || _acceptedLocally;
            final showAcceptSlot =
                !letter.outgoing && letter.status == LetterStatus.delivered;
            final canReply =
                !letter.outgoing &&
                letter.status == LetterStatus.delivered &&
                letter.peer.id.isNotEmpty;
            final peerTitle = letter.peer.nickname.isNotEmpty
                ? letter.peer.nickname
                : (letter.mode == LetterMode.postOffice
                      ? l10n.letterPeerPostOfficePool
                      : l10n.letterPeerUnknown);

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              children: [
                PostalCardEnvelope(
                  header: Row(
                    children: [
                      PostalAvatar(
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
                      _statusChip(letter),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.letterModeLine(_modeLabel(l10n, letter.mode)),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: PostalTokens.inkSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (letter.auditStatus != 1)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            l10n.letterAuditLine(
                              _auditLabel(l10n, letter.auditStatus),
                            ),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: PostalTokens.stampVermilion),
                          ),
                        ),
                      if (isRegistered)
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          child: Text(
                            'Registered mail: filing complete. It will show as delivered in a moment.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: PostalTokens.inkSecondary),
                          ),
                        )
                      else
                        const SizedBox(height: 10),
                      if (letter.contentHidden)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            height: 140,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Text(
                                  letter.body,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                BackdropFilter(
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
                                            color: PostalTokens.inkSecondary,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Text(
                          letter.body,
                          style: Theme.of(context).textTheme.bodyLarge,
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
                if (showAcceptSlot) ...[
                  const SizedBox(height: 14),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    child: PostalButton(
                      key: ValueKey(
                        connected
                            ? 'accepted_${letter.id}'
                            : 'accept_${letter.id}',
                      ),
                      label: connected
                          ? l10n.letterAcceptContactDone
                          : l10n.letterAcceptContact,
                      variant: connected
                          ? PostalButtonVariant.secondary
                          : PostalButtonVariant.primary,
                      busy: _acceptBusy,
                      onPressed: connected || _acceptBusy
                          ? null
                          : () async {
                              setState(() => _acceptBusy = true);
                              try {
                                final remote = ref.read(
                                  mailboxRemoteRepositoryProvider,
                                );
                                await remote.acceptPostalContact(letter.id);
                                try {
                                  await remote.syncImPeer(letter.peer.id);
                                } catch (e) {
                                  final imMsg = _postalApiUserMessage(e);
                                  if (context.mounted && imMsg != null) {
                                    PostalSnack.show(
                                      context,
                                      imMsg,
                                      tone: PostalSnackTone.warning,
                                    );
                                  }
                                }
                                if (!context.mounted) return;
                                setState(() => _acceptedLocally = true);
                                PostalSnack.show(
                                  context,
                                  l10n.letterAcceptContactSuccess,
                                  tone: PostalSnackTone.success,
                                );
                                ref.invalidate(
                                  letterDetailProvider(widget.letterId),
                                );
                                ref.invalidate(
                                  friendshipActiveProvider(letter.peer.id),
                                );
                                ref.invalidate(mailboxLettersProvider);
                                ref.invalidate(postalInboxLettersProvider);
                                ref.invalidate(mailboxFriendsProvider);
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
                ],
                const SizedBox(height: 16),
                if (canReply) ...[
                  Text(
                    'Reply uses the same rules as sending a new letter.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: PostalTokens.inkSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Builder(
                    builder: (context) {
                      final session = ref.watch(appSessionProvider);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _replyMailKindChip(
                                  context: context,
                                  title: 'Standard',
                                  subtitle: 'Free · delayed delivery',
                                  selected: _replyType == LetterType.standard,
                                  onTap: () => setState(
                                    () => _replyType = LetterType.standard,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _replyMailKindChip(
                                  context: context,
                                  title: 'Registered',
                                  subtitle: session.isVip
                                      ? 'VIP · filing mark · delayed'
                                      : 'Filing mark · delayed',
                                  selected: _replyType == LetterType.registered,
                                  onTap: () => setState(
                                    () => _replyType = LetterType.registered,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _replyType == LetterType.standard
                                ? 'Standard mail travels by the delivery formula; the recipient may see sealed text until it arrives.'
                                : 'Registered mail keeps a filing mark; delivery time still follows the slow-post formula.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: PostalTokens.inkTertiary,
                                  height: 1.4,
                                ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  PostalTextField(
                    controller: _reply,
                    label: 'Reply',
                    maxLines: 5,
                    minLines: 3,
                    showClearButton: true,
                  ),
                  const SizedBox(height: 12),
                  PostalButton(
                    label: 'Send reply',
                    busy: _replyBusy,
                    onPressed: _replyBusy
                        ? null
                        : () async {
                            final text = _reply.text.trim();
                            if (text.isEmpty) {
                              PostalSnack.show(
                                context,
                                'Please write your reply.',
                                tone: PostalSnackTone.warning,
                              );
                              return;
                            }
                            setState(() => _replyBusy = true);
                            try {
                              await ref
                                  .read(mailboxRemoteRepositoryProvider)
                                  .sendLetter(
                                    toUserId: letter.peer.id,
                                    content: text,
                                    type: _replyType,
                                    parentLetterId: letter.id,
                                  );
                              if (!context.mounted) return;
                              try {
                                await ref
                                    .read(authRepositoryProvider)
                                    .refreshSessionFromServer();
                              } catch (_) {}
                              if (!context.mounted) return;
                              _reply.clear();
                              ref.invalidate(
                                letterDetailProvider(widget.letterId),
                              );
                              ref.invalidate(mailboxLettersProvider);
                              ref.invalidate(mailboxArchiveProvider);
                              ref.invalidate(postalInboxLettersProvider);
                              PostalSnack.show(
                                context,
                                'Reply sent',
                                tone: PostalSnackTone.success,
                              );
                              if (context.canPop()) {
                                context.pop();
                              }
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
                                setState(() => _replyBusy = false);
                              }
                            }
                          },
                  ),
                ] else ...[
                  Text(
                    'Reply is available after the letter is received (not while delivering).',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: PostalTokens.inkSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  PostalTextField(
                    controller: _reply,
                    label: 'Reply draft',
                    maxLines: 5,
                    minLines: 4,
                    showClearButton: false,
                    enabled: false,
                  ),
                  const SizedBox(height: 12),
                  PostalButton(label: 'Send reply', onPressed: null),
                ],
                if (connected) ...[
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => context.push(
                      '/chat/${letter.peer.id}',
                      extra: <String, dynamic>{
                        'name': letter.peer.nickname,
                        'avatarUrl': letter.peer.avatarUrl,
                        'trustedFriendship': true,
                      },
                    ),
                    child: const Text('Open instant chat'),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
