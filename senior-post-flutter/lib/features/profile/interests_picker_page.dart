import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/postal_tokens.dart';
import '../../core/api/api_exception.dart';
import '../../core/models/interest_tag_option.dart';
import '../../core/session/app_session.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/postal/postal.dart';
import '../auth/auth_repository.dart';
import '../directory/directory_remote.dart';

final _pickerInterestOptionsProvider =
    FutureProvider.family<List<InterestTagOption>, String>((ref, lang) async {
      return ref
          .read(directoryRemoteProvider)
          .listInterestTagOptions(lang: lang);
    });

class InterestsPickerPage extends ConsumerStatefulWidget {
  const InterestsPickerPage({super.key});

  @override
  ConsumerState<InterestsPickerPage> createState() =>
      _InterestsPickerPageState();
}

class _InterestsPickerPageState extends ConsumerState<InterestsPickerPage> {
  final Set<int> _selected = {};
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final u = ref.read(appSessionProvider).user;
    _selected.addAll(u.interestTagIds);
  }

  Future<void> _save(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    if (_selected.length < 3) {
      PostalSnack.show(
        context,
        l10n.authRegisterInterestsMin,
        tone: PostalSnackTone.warning,
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .updateProfileOnServer(interestTagIds: _selected.toList());
      if (!context.mounted) {
        return;
      }
      PostalSnack.show(
        context,
        l10n.interestsPickerSaved,
        tone: PostalSnackTone.success,
      );
      Navigator.of(context).pop();
    } on ApiBusinessException catch (e) {
      if (context.mounted) {
        PostalSnack.show(
          context,
          e.message.isNotEmpty ? e.message : 'Failed to save interests',
          tone: PostalSnackTone.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final asyncOpts = ref.watch(_pickerInterestOptionsProvider(lang));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.interestsPickerTitle)),
      body: SafeArea(
        child: asyncOpts.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => PostalEmptyState(
            title: l10n.commonLoadFailed,
            subtitle: l10n.commonLoadFailedHint,
            tone: PostalEmptyTone.error,
            actionLabel: l10n.commonRetry,
            onAction: () =>
                ref.invalidate(_pickerInterestOptionsProvider(lang)),
          ),
          data: (options) {
            if (options.isEmpty) {
              return PostalEmptyState(
                title: l10n.commonLoadFailed,
                subtitle: l10n.interestsPickerEmpty,
                actionLabel: l10n.commonRetry,
                onAction: () =>
                    ref.invalidate(_pickerInterestOptionsProvider(lang)),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                  child: Text(
                    l10n.interestsPickerSelected(_selected.length),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: PostalTokens.inkSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                    children: [
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: options.map((o) {
                          final selected = _selected.contains(o.id);
                          return FilterChip(
                            label: Text(o.tagName),
                            selected: selected,
                            showCheckmark: true,
                            color: WidgetStatePropertyAll(
                              selected
                                  ? PostalTokens.postboxGreen
                                  : PostalTokens.paperEnvelope,
                            ),
                            checkmarkColor: Colors.white,
                            labelStyle: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : PostalTokens.inkNavy,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            side: BorderSide(
                              color: selected
                                  ? PostalTokens.postboxGreen
                                  : PostalTokens.perforationLine,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            onSelected: (v) {
                              setState(() {
                                if (v) {
                                  _selected.add(o.id);
                                } else {
                                  _selected.remove(o.id);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: PostalButton(
                    label: l10n.interestsPickerSave,
                    busy: _saving,
                    onPressed: _saving ? null : () => _save(context),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
