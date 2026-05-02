import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/mock/mock_data.dart';
import '../../core/mock/mock_repository.dart';
import '../../widgets/postal/postal.dart';

class ProfileEditPage extends ConsumerStatefulWidget {
  const ProfileEditPage({super.key});

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  late final TextEditingController _nickname;
  late final TextEditingController _bio;
  String? _countryCode;

  @override
  void initState() {
    super.initState();
    final user = ref.read(mockSessionProvider).user;
    _nickname = TextEditingController(text: user.nickname);
    _bio = TextEditingController(text: user.bio);
    _countryCode = user.countryCode;
  }

  @override
  void dispose() {
    _nickname.dispose();
    _bio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          children: [
            PostalTextField(controller: _nickname, label: 'Nickname'),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              // ignore: deprecated_member_use
              value: _countryCode,
              decoration: const InputDecoration(labelText: 'Country'),
              items: MockData.countries
                  .map(
                    (c) => DropdownMenuItem<String>(
                      value: c.code,
                      child: Text('${c.nameEn} (${c.code})'),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _countryCode = v),
            ),
            const SizedBox(height: 12),
            PostalTextField(
              controller: _bio,
              label: 'Bio',
              maxLines: 6,
              minLines: 4,
              showClearButton: false,
            ),
            const SizedBox(height: 14),
            PostalButton(
              label: 'Save',
              onPressed: () {
                final country = MockData.countries.firstWhere(
                  (c) => c.code == _countryCode,
                  orElse: () => MockData.countries.first,
                );
                ref.read(mockSessionProvider.notifier).updateProfile(
                      nickname: _nickname.text.trim(),
                      bio: _bio.text.trim(),
                      countryCode: country.code,
                      countryName: country.nameEn,
                    );
                PostalSnack.show(
                  context,
                  'Mock: profile updated',
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
