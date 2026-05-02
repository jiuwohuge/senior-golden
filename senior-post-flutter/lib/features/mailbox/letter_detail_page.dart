// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/api/api_exception.dart';
import '../../core/mock/mock_models.dart';
import '../../core/mock/mock_repository.dart';
import '../../widgets/postal/postal.dart';
import 'mailbox_page.dart';
import 'speed_up_sheet.dart';

final letterDetailProvider = FutureProvider.family<MockLetter?, String>((ref, id) async {
  return ref.read(mockMailboxRepositoryProvider).findById(id);
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

  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final letterAsync = ref.watch(letterDetailProvider(widget.letterId));
    return Scaffold(
      appBar: AppBar(title: const Text('Letter detail')),
      body: SafeArea(
        child: letterAsync.when(
          loading: () => const PostalSkeletonList(itemCount: 1, itemHeight: 260),
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
                      isDelivering
                          ? PostalStatusChip.delivering()
                          : PostalStatusChip.delivered(),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(letter.body, style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 12),
                      Text(
                        'Sent at ${DateFormat('MM-dd HH:mm').format(letter.sentAt)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (letter.deliveryAt != null)
                        Text(
                          '${isDelivering ? 'Estimated delivery' : 'Delivered'} ${DateFormat('MM-dd HH:mm').format(letter.deliveryAt!)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                  footer: isDelivering
                      ? Row(
                          children: [
                            Expanded(
                              child: PostalButton(
                                label: 'Speed Up',
                                onPressed: () async {
                                  await showModalBottomSheet<void>(
                                    context: context,
                                    builder: (_) => SpeedUpSheet(letterId: letter.id),
                                  );
                                  ref.invalidate(letterDetailProvider(widget.letterId));
                                  ref.invalidate(mailboxLettersProvider);
                                },
                              ),
                            ),
                          ],
                        )
                      : null,
                ),
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
                  label: 'Send reply',
                  busy: _busy,
                  onPressed: _busy
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
                            await ref.read(mockMailboxRepositoryProvider).reply(
                                  letter.id,
                                  _reply.text.trim(),
                                );
                            if (!context.mounted) return;
                            PostalSnack.show(
                              context,
                              'Mock: reply sent',
                              tone: PostalSnackTone.success,
                            );
                            _reply.clear();
                            ref.invalidate(mailboxLettersProvider);
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
              ],
            );
          },
        ),
      ),
    );
  }
}
