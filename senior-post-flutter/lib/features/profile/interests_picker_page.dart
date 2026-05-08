import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_exception.dart';
import '../../core/env/app_env.dart';
import '../../core/models/interest_tag_option.dart';
import '../../core/mock/mock_data.dart';
import '../../core/mock/mock_repository.dart';
import '../../widgets/postal/postal.dart';
import '../auth/auth_repository.dart';
import '../directory/directory_remote.dart';

final _pickerInterestOptionsProvider =
    FutureProvider.family<List<InterestTagOption>, String>((ref, lang) async {
      return ref.read(directoryRemoteProvider).listInterestTagOptions(lang: lang);
    });

class InterestsPickerPage extends ConsumerStatefulWidget {
  const InterestsPickerPage({super.key});

  @override
  ConsumerState<InterestsPickerPage> createState() => _InterestsPickerPageState();
}

class _InterestsPickerPageState extends ConsumerState<InterestsPickerPage> {
  final Set<String> _mockSelected = {};
  final Set<int> _realSelected = {};
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final u = ref.read(mockSessionProvider).user;
    if (AppEnv.useMock) {
      _mockSelected.addAll(u.interests);
    } else {
      _realSelected.addAll(u.interestTagIds);
    }
  }

  Future<void> _saveReal(BuildContext context) async {
    if (_realSelected.length < 3) {
      PostalSnack.show(
        context,
        'Please select at least 3 interests.',
        tone: PostalSnackTone.warning,
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(authRepositoryProvider).updateProfileOnServer(
            interestTagIds: _realSelected.toList(),
          );
      if (!context.mounted) {
        return;
      }
      PostalSnack.show(
        context,
        'Interests saved',
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
    if (AppEnv.useMock) {
      return Scaffold(
        appBar: AppBar(title: const Text('Interest tags')),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: MockData.interests
                    .map(
                      (e) => FilterChip(
                        label: Text(e.label),
                        selected: _mockSelected.contains(e.id),
                        onSelected: (v) {
                          setState(() {
                            if (v) {
                              _mockSelected.add(e.id);
                            } else {
                              _mockSelected.remove(e.id);
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
                onPressed: () {
                  if (_mockSelected.length < 3) {
                    PostalSnack.show(
                      context,
                      'Please select at least 3 interests.',
                      tone: PostalSnackTone.warning,
                    );
                    return;
                  }
                  ref.read(mockSessionProvider.notifier).updateProfile(
                        interests: _mockSelected.toList(),
                      );
                  PostalSnack.show(
                    context,
                    'Mock: interests updated',
                    tone: PostalSnackTone.success,
                  );
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      );
    }

    final lang = Localizations.localeOf(context).languageCode;
    final asyncOpts = ref.watch(_pickerInterestOptionsProvider(lang));

    return Scaffold(
      appBar: AppBar(title: const Text('Interest tags')),
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
                          selected: _realSelected.contains(o.id),
                          onSelected: (v) {
                            setState(() {
                              if (v) {
                                _realSelected.add(o.id);
                              } else {
                                _realSelected.remove(o.id);
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
                  onPressed: _saving ? null : () => _saveReal(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
