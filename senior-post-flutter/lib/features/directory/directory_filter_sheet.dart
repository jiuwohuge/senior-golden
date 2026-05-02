import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/mock/mock_data.dart';
import '../../widgets/postal/postal.dart';
import 'directory_page.dart';

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

  @override
  void initState() {
    super.initState();
    final f = ref.read(directoryFilterProvider);
    _countryCode = f.countryCode;
    _minAge = f.minAge;
    _maxAge = f.maxAge;
    _interests.addAll(f.interests);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: ListView(
          shrinkWrap: true,
          children: [
            const PostalSectionTitle(
              title: 'Filter directory',
              subtitle: 'Country, age range, and interests',
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
                ...MockData.countries.map(
                  (c) => DropdownMenuItem<String?>(
                    value: c.code,
                    child: Text('${c.nameEn} (${c.code})'),
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
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MockData.interests
                  .map(
                    (i) => FilterChip(
                      label: Text(i.label),
                      selected: _interests.contains(i.id),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _interests.add(i.id);
                          } else {
                            _interests.remove(i.id);
                          }
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
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
    );
  }
}
