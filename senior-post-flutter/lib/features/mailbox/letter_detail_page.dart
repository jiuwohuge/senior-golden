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
import 'speed_up_sheet.dart';

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
  bool _replyBusy = false;
  bool _earlyOpenBusy = false;
  LetterType _replyType = LetterType.standard;

  @override
  void dispose() {
    ref.invalidate(postalInboxLettersProvider);
    _reply.dispose();
    super.dispose();
  }

  Widget _statusChip(MailboxLetter letter) {
    return switch (letter.status) {
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
            final isDelivering = letter.status == LetterStatus.delivering;
            final isRegistered = letter.status == LetterStatus.registered;
            final friendsAsync = ref.watch(
              friendshipActiveProvider(letter.peer.id),
            );
            final isFriend = friendsAsync.valueOrNull ?? false;
            final canAccept =
                !letter.outgoing &&
                letter.status == LetterStatus.delivered &&
                !isFriend;
            final canReply =
                !letter.outgoing &&
                letter.status != LetterStatus.delivering &&
                letter.peer.id.isNotEmpty;

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              children: [
                PostalCardEnvelope(
                  header: Row(
                    children: [
                      PostalAvatar(
                        name: letter.peer.nickname,
                        size: 40,
                        imageUrl: letter.peer.avatarUrl,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          letter.peer.nickname,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      _statusChip(letter),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isRegistered)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            'Registered mail: filing complete. It will show as delivered in a moment.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: PostalTokens.inkSecondary),
                          ),
                        ),
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
                        'Sent at ${DateFormat('MM-dd HH:mm').format(letter.sentAt)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (letter.deliveryAt != null)
                        Text(
                          '${isDelivering
                              ? 'Estimated delivery'
                              : isRegistered
                              ? 'Expected delivery'
                              : 'Delivered'} ${DateFormat('MM-dd HH:mm').format(letter.deliveryAt!)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                  footer: () {
                    final foot = <Widget>[];
                    if (isDelivering &&
                        letter.outgoing &&
                        letter.type == LetterType.standard) {
                      foot.add(
                        PostalButton(
                          label: 'Speed Up',
                          onPressed: () async {
                            await showModalBottomSheet<void>(
                              context: context,
                              builder: (_) => SpeedUpSheet(letterId: letter.id),
                            );
                            ref.invalidate(
                              letterDetailProvider(widget.letterId),
                            );
                            ref.invalidate(mailboxLettersProvider);
                            ref.invalidate(postalInboxLettersProvider);
                          },
                        ),
                      );
                    }
                    if (isDelivering &&
                        !letter.outgoing &&
                        letter.type == LetterType.standard &&
                        letter.contentHidden) {
                      foot.add(
                        PostalButton(
                          label: l10n.letterEarlyOpenCta,
                          busy: _earlyOpenBusy,
                          onPressed: _earlyOpenBusy
                              ? null
                              : () async {
                                  setState(() => _earlyOpenBusy = true);
                                  try {
                                    await ref
                                        .read(mailboxRemoteRepositoryProvider)
                                        .earlyOpen(letter.id);
                                    if (!context.mounted) {
                                      return;
                                    }
                                    await ref
                                        .read(authRepositoryProvider)
                                        .refreshSessionFromServer();
                                    if (!context.mounted) {
                                      return;
                                    }
                                    ref.invalidate(
                                      letterDetailProvider(widget.letterId),
                                    );
                                    ref.invalidate(mailboxLettersProvider);
                                    ref.invalidate(postalInboxLettersProvider);
                                    ref.invalidate(mailboxArchiveProvider);
                                    PostalSnack.show(
                                      context,
                                      l10n.letterEarlyOpenSuccess,
                                      tone: PostalSnackTone.success,
                                    );
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
                                    if (mounted) {
                                      setState(() => _earlyOpenBusy = false);
                                    }
                                  }
                                },
                        ),
                      );
                    }
                    if (foot.isEmpty) {
                      return null;
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < foot.length; i++) ...[
                          if (i > 0) const SizedBox(height: 10),
                          foot[i],
                        ],
                      ],
                    );
                  }(),
                ),
                if (canAccept) ...[
                  const SizedBox(height: 14),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    child: PostalButton(
                      key: ValueKey('accept_${letter.id}'),
                      label: 'Accept postal contact',
                      busy: _acceptBusy,
                      onPressed: _acceptBusy
                          ? null
                          : () async {
                              setState(() => _acceptBusy = true);
                              try {
                                await ref
                                    .read(mailboxRemoteRepositoryProvider)
                                    .acceptPostalContact(letter.id);
                                if (!context.mounted) return;
                                PostalSnack.show(
                                  context,
                                  'You can open chat from Connections (your postal friends).',
                                  tone: PostalSnackTone.success,
                                );
                                ref.invalidate(
                                  letterDetailProvider(widget.letterId),
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
                                      ? 'VIP · instant delivery'
                                      : '1 stamp · instant delivery',
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
                                ? 'Standard mail travels for a while; the recipient may see blurred text until it arrives.'
                                : 'Registered mail is treated as delivered immediately so the full letter is readable at once.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: PostalTokens.inkTertiary,
                                  height: 1.4,
                                ),
                          ),
                          if (_replyType == LetterType.registered &&
                              !session.isVip) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Your stamps: ${session.stampBalance}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: session.stampBalance < 1
                                        ? PostalTokens.stampVermilion
                                        : PostalTokens.inkSecondary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
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
                            final session = ref.read(appSessionProvider);
                            if (_replyType == LetterType.registered &&
                                !session.isVip &&
                                session.stampBalance < 1) {
                              PostalSnack.show(
                                context,
                                'Not enough stamps for registered mail.',
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
                if (isFriend) ...[
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => context.push('/chat/${letter.peer.id}'),
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
