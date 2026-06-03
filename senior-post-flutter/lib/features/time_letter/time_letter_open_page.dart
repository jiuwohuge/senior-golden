import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../app/theme/postal_tokens.dart';
import '../../core/api/api_exception.dart';
import '../../widgets/postal/postal.dart';
import 'time_letter_providers.dart';
import 'time_letter_remote.dart';

class TimeLetterOpenPage extends ConsumerStatefulWidget {
  const TimeLetterOpenPage({super.key, required this.letterId});

  final String letterId;

  @override
  ConsumerState<TimeLetterOpenPage> createState() => _TimeLetterOpenPageState();
}

class _TimeLetterOpenPageState extends ConsumerState<TimeLetterOpenPage>
    with SingleTickerProviderStateMixin {
  bool _revealed = false;
  bool _opening = false;
  late final AnimationController _envelopeCtrl;

  @override
  void initState() {
    super.initState();
    _envelopeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    _envelopeCtrl.dispose();
    super.dispose();
  }

  Future<void> _performOpen(TimeLetterDetail detail) async {
    if (_opening || detail.status == 4) {
      setState(() => _revealed = true);
      return;
    }
    if (!detail.canOpen) return;
    setState(() => _opening = true);
    try {
      await _envelopeCtrl.forward();
      await ref.read(timeLetterRemoteProvider).open(widget.letterId);
      invalidateTimeLetterLists(ref);
      ref.invalidate(timeLetterDetailProvider(widget.letterId));
      if (mounted) setState(() => _revealed = true);
    } on ApiBusinessException catch (e) {
      if (mounted) {
        PostalSnack.show(context, e.message, tone: PostalSnackTone.error);
      }
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(timeLetterDetailProvider(widget.letterId));

    return Scaffold(
      backgroundColor: PostalTokens.paperCream,
      appBar: AppBar(
        backgroundColor: PostalTokens.postboxGreen,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(l10n.timeLetterOpenTitle),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => PostalEmptyState(
          title: l10n.timeLetterLoadError,
          subtitle: '$e',
          tone: PostalEmptyTone.error,
        ),
        data: (detail) {
          if (!_revealed && detail.status == 4) {
            _revealed = true;
          }
          final readMin = detail.estimatedReadMinutes ?? 1;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!_revealed) ...[
                    Expanded(
                      child: Center(
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 1, end: 1.08).animate(
                            CurvedAnimation(
                              parent: _envelopeCtrl,
                              curve: Curves.easeOutBack,
                            ),
                          ),
                          child: Icon(
                            Icons.mail_outline,
                            size: 120,
                            color: PostalTokens.postboxGreen.withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                    ),
                    FilledButton(
                      onPressed: _opening ? null : () => _performOpen(detail),
                      child: Text(l10n.timeLetterOpenRitual),
                    ),
                  ] else ...[
                    Text(
                      detail.senderNickname ?? '',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.timeLetterReadEstimate(readMin),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: PostalTokens.inkTertiary,
                          ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          detail.body ?? '',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontSize: 22,
                                height: 1.55,
                              ),
                        ),
                      ),
                    ),
                    if (detail.status == 4)
                      TextButton.icon(
                        onPressed: () async {
                          await ref
                              .read(timeLetterRemoteProvider)
                              .toggleStar(widget.letterId);
                          ref.invalidate(timeLetterDetailProvider(widget.letterId));
                          invalidateTimeLetterLists(ref);
                        },
                        icon: Icon(
                          detail.starFlag
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: PostalTokens.stampGold,
                        ),
                        label: Text(
                          detail.starFlag
                              ? l10n.timeLetterStarred
                              : l10n.timeLetterStar,
                        ),
                      ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
