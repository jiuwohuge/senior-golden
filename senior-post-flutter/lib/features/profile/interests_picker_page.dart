import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/mock/mock_data.dart';
import '../../core/mock/mock_repository.dart';
import '../../widgets/postal/postal.dart';

class InterestsPickerPage extends ConsumerStatefulWidget {
  const InterestsPickerPage({super.key});

  @override
  ConsumerState<InterestsPickerPage> createState() => _InterestsPickerPageState();
}

class _InterestsPickerPageState extends ConsumerState<InterestsPickerPage> {
  final Set<String> _selected = {};

  @override
  void initState() {
    super.initState();
    _selected.addAll(ref.read(mockSessionProvider).user.interests);
  }

  @override
  Widget build(BuildContext context) {
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
                      selected: _selected.contains(e.id),
                      onSelected: (v) {
                        setState(() {
                          if (v) {
                            _selected.add(e.id);
                          } else {
                            _selected.remove(e.id);
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
                if (_selected.length < 3) {
                  PostalSnack.show(
                    context,
                    'Please select at least 3 interests.',
                    tone: PostalSnackTone.warning,
                  );
                  return;
                }
                ref.read(mockSessionProvider.notifier).updateProfile(
                      interests: _selected.toList(),
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
}
