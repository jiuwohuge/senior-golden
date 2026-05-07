import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_exception.dart';
import '../../core/env/app_env.dart';
import '../../core/mock/mock_data.dart';
import '../../core/mock/mock_repository.dart';
import '../auth/auth_repository.dart';
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
  bool _loadingMe = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(mockSessionProvider).user;
    _nickname = TextEditingController(text: user.nickname);
    _bio = TextEditingController(text: user.bio);
    _countryCode = user.countryCode.isEmpty ? null : user.countryCode;
    if (!AppEnv.useMock) {
      _loadingMe = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _pullMe());
    }
  }

  Future<void> _pullMe() async {
    try {
      await ref.read(authRepositoryProvider).refreshSessionFromServer();
      if (!mounted) return;
      final u = ref.read(mockSessionProvider).user;
      setState(() {
        _nickname.text = u.nickname;
        _bio.text = u.bio;
        _countryCode = u.countryCode.isEmpty ? null : u.countryCode;
        _loadingMe = false;
      });
    } on ApiBusinessException catch (e) {
      if (mounted) {
        PostalSnack.show(context, e.message, tone: PostalSnackTone.error);
        setState(() => _loadingMe = false);
      }
    } catch (e) {
      if (mounted) {
        PostalSnack.show(context, '$e', tone: PostalSnackTone.error);
        setState(() => _loadingMe = false);
      }
    }
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
        child: _loadingMe
            ? const Center(child: CircularProgressIndicator())
            : ListView(
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
                    busy: _saving,
                    onPressed: _saving ? null : () => _onSave(context),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _onSave(BuildContext context) async {
    final country = MockData.countries.firstWhere(
      (c) => c.code == _countryCode,
      orElse: () => MockData.countries.first,
    );
    if (AppEnv.useMock) {
      ref.read(mockSessionProvider.notifier).updateProfile(
            nickname: _nickname.text.trim(),
            bio: _bio.text.trim(),
            countryCode: country.code,
            countryName: country.nameEn,
          );
      if (context.mounted) {
        PostalSnack.show(
          context,
          'Mock: profile updated',
          tone: PostalSnackTone.success,
        );
        Navigator.of(context).pop();
      }
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(authRepositoryProvider).updateProfileOnServer(
            nickname: _nickname.text.trim(),
            countryCode: country.code,
            bio: _bio.text,
          );
      if (context.mounted) {
        PostalSnack.show(
          context,
          'Profile saved',
          tone: PostalSnackTone.success,
        );
        Navigator.of(context).pop();
      }
    } on ApiBusinessException catch (e) {
      if (context.mounted) {
        PostalSnack.show(context, e.message, tone: PostalSnackTone.error);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
