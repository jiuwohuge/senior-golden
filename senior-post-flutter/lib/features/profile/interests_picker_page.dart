import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
          error: (e, _) => Center(child: Text('$e')),
          data: (options) {
            if (options.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No interest tags from server. Add tags in admin or try another language.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              );
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: options
                      .map(
                        (o) => FilterChip(
                          label: Text(o.tagName),
                          selected: _selected.contains(o.id),
                          onSelected: (v) {
                            setState(() {
                              if (v) {
                                _selected.add(o.id);
                              } else {
                                _selected.remove(o.id);
                              }
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 14),
                PostalButton(
                  label: 'Save interests',
                  busy: _saving,
                  onPressed: _saving ? null : () => _save(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
