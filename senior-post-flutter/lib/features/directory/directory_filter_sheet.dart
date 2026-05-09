import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/bootstrap/app_bootstrap.dart';
import '../../widgets/postal/postal.dart';
import 'directory_providers.dart';
import 'directory_remote.dart';

/// 筛选「兴趣」选项：`value` 为 `sys_tag.tag_name`，提交给 `interestNames`。
class DirectoryFilterTagOption {
  const DirectoryFilterTagOption({required this.value, required this.label});

  final String value;
  final String label;
}

final directoryFilterTagOptionsProvider =
    FutureProvider.family<List<DirectoryFilterTagOption>, String>((ref, lang) async {
  final options = await ref.read(directoryRemoteProvider).listInterestTagOptions(lang: lang);
  return options
      .map((o) => DirectoryFilterTagOption(value: o.tagName, label: o.tagName))
      .toList();
});

class DirectoryFilterSheet extends ConsumerStatefulWidget {
  const DirectoryFilterSheet({super.key});

  @override
  ConsumerState<DirectoryFilterSheet> createState() => _DirectoryFilterSheetState();
}

class _DirectoryFilterSheetState extends ConsumerState<DirectoryFilterSheet> {
  String? _countryCode;
  int _minAge = 45;
  int _maxAge = 80;
  final Set<String> _interests = {};
  String _sort = 'DEFAULT';

  @override
  void initState() {
    super.initState();
    final f = ref.read(directoryFilterProvider);
    _countryCode = f.countryCode;
    _minAge = f.minAge;
    _maxAge = f.maxAge;
    _interests.addAll(f.interests);
    _sort = f.sort;
  }

  Widget _chipsForOptions(List<DirectoryFilterTagOption> options) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options
          .map(
            (i) => FilterChip(
              label: Text(i.label),
              selected: _interests.contains(i.value),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _interests.add(i.value);
                  } else {
                    _interests.remove(i.value);
                  }
                });
              },
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final bootstrapAsync = ref.watch(appBootstrapProvider(lang));
    final tagsAsync = ref.watch(directoryFilterTagOptionsProvider(lang));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: bootstrapAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (bootstrap) => tagsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (tagOptions) => ListView(
              shrinkWrap: true,
              children: [
                const PostalSectionTitle(
                  title: 'Filter directory',
                  subtitle: 'Country, age range, interests, and sort',
                ),
                const SizedBox(height: 8),
                Text('Sort', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Newest'),
                      selected: _sort == 'DEFAULT',
                      onSelected: (_) => setState(() => _sort = 'DEFAULT'),
                    ),
                    ChoiceChip(
                      label: const Text('Closest age'),
                      selected: _sort == 'SAME_AGE',
                      onSelected: (_) => setState(() => _sort = 'SAME_AGE'),
                    ),
                    ChoiceChip(
                      label: const Text('Shared interests'),
                      selected: _sort == 'SHARED_INTEREST',
                      onSelected: (_) => setState(() => _sort = 'SHARED_INTEREST'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String?>(
                  // ignore: deprecated_member_use
                  value: _countryCode,
                  decoration: const InputDecoration(labelText: 'Country'),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('All countries'),
                    ),
                    ...bootstrap.countries.map(
                      (c) => DropdownMenuItem<String?>(
                        value: c.code,
                        child: Text('${c.displayName(lang)} (${c.code})'),
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => _countryCode = v),
                ),
                const SizedBox(height: 14),
                Text('Min age: $_minAge'),
                Slider(
                  min: 45,
                  max: 90,
                  value: _minAge.toDouble(),
                  divisions: 45,
                  label: '$_minAge',
                  onChanged: (v) => setState(() => _minAge = v.round()),
                ),
                const SizedBox(height: 8),
                Text('Max age: $_maxAge'),
                Slider(
                  min: 45,
                  max: 100,
                  value: _maxAge.toDouble(),
                  divisions: 55,
                  label: '$_maxAge',
                  onChanged: (v) => setState(() => _maxAge = v.round()),
                ),
                const SizedBox(height: 8),
                if (tagOptions.isEmpty)
                  Text(
                    'No interest tags from server. Add tags in admin or try another language.',
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                else
                  _chipsForOptions(tagOptions),
                const SizedBox(height: 16),
                PostalButton(
                  label: 'Apply filters',
                  onPressed: () {
                    final min = _minAge <= _maxAge ? _minAge : _maxAge;
                    final max = _maxAge >= _minAge ? _maxAge : _minAge;
                    ref.read(directoryFilterProvider.notifier).state = DirectoryFilter(
                          countryCode: _countryCode,
                          minAge: min,
                          maxAge: max,
                          interests: _interests,
                          sort: _sort,
                        );
                    ref.invalidate(directoryUsersProvider);
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 8),
                PostalButton(
                  label: 'Clear',
                  variant: PostalButtonVariant.secondary,
                  onPressed: () {
                    ref.read(directoryFilterProvider.notifier).state = const DirectoryFilter();
                    ref.invalidate(directoryUsersProvider);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
