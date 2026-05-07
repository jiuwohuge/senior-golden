// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/theme/postal_tokens.dart';
import '../../core/api/api_exception.dart';
import '../../core/env/app_env.dart';
import '../../core/mock/mock_models.dart';
import '../../core/mock/mock_repository.dart';
import '../../widgets/postal/postal.dart';
import 'mailbox_providers.dart';
import 'mailbox_remote.dart';
import 'speed_up_sheet.dart';

final letterDetailProvider = FutureProvider.family<MockLetter?, String>((
  ref,
  id,
) async {
  if (AppEnv.useMock) {
    return ref.read(mockMailboxRepositoryProvider).findById(id);
  }
  return ref.read(mailboxRemoteRepositoryProvider).getLetter(id);
});

class LetterDetailPage extends ConsumerStatefulWidget {
  const LetterDetailPage({super.key, required this.letterId});
  final String letterId;

  @override
  ConsumerState<LetterDetailPage> createState() => _LetterDetailPageState();
}

class _LetterDetailPageState extends ConsumerState<LetterDetailPage> {
  final _reply = TextEditingController();
  bool _busy = false;
  bool _acceptBusy = false;

  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  Widget _statusChip(MockLetter letter) {
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
    return Scaffold(
      appBar: AppBar(title: const Text('Letter detail')),
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
            final AsyncValue<bool>? friendsAsync = AppEnv.useMock
                ? null
                : ref.watch(friendshipActiveProvider(letter.peer.id));
            final isFriend = AppEnv.useMock
                ? ref.read(mockMailboxRepositoryProvider).friendsWithPeer(letter.peer.id)
                : (friendsAsync!.valueOrNull ?? false);
            final canAccept =
                !letter.outgoing &&
                letter.status == LetterStatus.delivered &&
                !isFriend;

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              children: [
                PostalCardEnvelope(
                  header: Row(
                    children: [
                      PostalAvatar(name: letter.peer.nickname, size: 40),
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
                  footer: isDelivering &&
                          letter.outgoing &&
                          letter.type == LetterType.standard
                      ? Row(
                          children: [
                            Expanded(
                              child: PostalButton(
                                label: 'Speed Up',
                                onPressed: () async {
                                  await showModalBottomSheet<void>(
                                    context: context,
                                    builder: (_) =>
                                        SpeedUpSheet(letterId: letter.id),
                                  );
                                  ref.invalidate(
                                    letterDetailProvider(widget.letterId),
                                  );
                                  ref.invalidate(mailboxLettersProvider);
                                  ref.invalidate(postalInboxLettersProvider);
                                },
                              ),
                            ),
                          ],
                        )
                      : null,
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
                                if (AppEnv.useMock) {
                                  await ref
                                      .read(mockMailboxRepositoryProvider)
                                      .acceptPostalConnection(letter.id);
                                } else {
                                  await ref
                                      .read(mailboxRemoteRepositoryProvider)
                                      .acceptPostalContact(letter.id);
                                }
                                if (!context.mounted) return;
                                PostalSnack.show(
                                  context,
                                  'You can now chat in Connections.',
                                  tone: PostalSnackTone.success,
                                );
                                ref.invalidate(
                                  letterDetailProvider(widget.letterId),
                                );
                                ref.invalidate(mailboxLettersProvider);
                                ref.invalidate(postalInboxLettersProvider);
                                ref.invalidate(mockConnectionsProvider);
                                ref.invalidate(
                                  friendshipActiveProvider(letter.peer.id),
                                );
                                ref.invalidate(timConversationsProvider);
                              } on ApiBusinessException catch (e) {
                                if (context.mounted) {
                                  PostalSnack.show(
                                    context,
                                    e.message,
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
                PostalTextField(
                  controller: _reply,
                  label: 'Reply',
                  maxLines: 5,
                  minLines: 4,
                  showClearButton: false,
                ),
                const SizedBox(height: 12),
                PostalButton(
                  label: AppEnv.useMock ? 'Send reply' : 'Send reply (soon)',
                  busy: _busy,
                  onPressed: (!AppEnv.useMock ||
                          letter.status != LetterStatus.delivered ||
                          _busy)
                      ? null
                      : () async {
                          if (_reply.text.trim().isEmpty) {
                            PostalSnack.show(
                              context,
                              'Please enter reply content.',
                              tone: PostalSnackTone.warning,
                            );
                            return;
                          }
                          setState(() => _busy = true);
                          try {
                            await ref
                                .read(mockMailboxRepositoryProvider)
                                .reply(letter.id, _reply.text.trim());
                            if (!context.mounted) return;
                            PostalSnack.show(
                              context,
                              'Mock: reply sent',
                              tone: PostalSnackTone.success,
                            );
                            _reply.clear();
                            ref.invalidate(mailboxLettersProvider);
                            ref.invalidate(postalInboxLettersProvider);
                          } on ApiBusinessException catch (e) {
                            if (context.mounted) {
                              PostalSnack.show(
                                context,
                                e.message,
                                tone: PostalSnackTone.error,
                              );
                            }
                          } finally {
                            if (context.mounted) setState(() => _busy = false);
                          }
                        },
                ),
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
