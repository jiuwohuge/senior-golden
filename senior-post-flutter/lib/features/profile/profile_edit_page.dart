import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../core/api/api_exception.dart';
import '../../core/env/app_env.dart';
import '../../core/mock/mock_data.dart';
import '../../core/mock/mock_repository.dart';
import '../../core/oss/oss_upload_service.dart';
import '../../app/theme/postal_tokens.dart';
import '../../widgets/postal/postal.dart';
import '../auth/auth_repository.dart';
import 'avatar_crop_page.dart';

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
  bool _avatarBusy = false;
  Uint8List? _avatarPreviewBytes;

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
        _avatarPreviewBytes = null;
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

  Future<void> _onChangeAvatar() async {
    final l10n = AppLocalizations.of(context)!;
    if (AppEnv.useMock) {
      ref.read(mockSessionProvider.notifier).updateProfile(avatarUrl: 'mock://avatar');
      setState(() => _avatarPreviewBytes = null);
      if (mounted) {
        PostalSnack.show(context, l10n.profileMockUpdated, tone: PostalSnackTone.success);
      }
      return;
    }
    if (_avatarBusy || _saving) return;
    final XFile? x;
    try {
      final picker = ImagePicker();
      x = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 92,
      );
    } on PlatformException catch (e) {
      if (mounted) {
        PostalSnack.show(context, e.message ?? e.code, tone: PostalSnackTone.error);
      }
      return;
    }
    if (x == null) return;
    final raw = await x.readAsBytes();
    if (!mounted) return;
    final cropped = await Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(
        builder: (_) => AvatarCropPage(imageBytes: raw),
      ),
    );
    if (cropped == null || !mounted) return;
    setState(() {
      _avatarBusy = true;
      _avatarPreviewBytes = cropped;
    });
    try {
      final key = await ref.read(ossUploadServiceProvider).uploadAvatarImage(
            bytes: cropped,
            ext: 'jpg',
            contentType: 'image/jpeg',
          );
      await ref.read(authRepositoryProvider).updateProfileOnServer(
            nickname: _nickname.text.trim(),
            countryCode: _countryCode,
            bio: _bio.text,
            avatarUrl: key,
          );
      if (mounted) {
        setState(() => _avatarPreviewBytes = null);
        PostalSnack.show(context, l10n.profileSaved, tone: PostalSnackTone.success);
      }
    } on ApiBusinessException catch (e) {
      if (mounted) PostalSnack.show(context, e.message, tone: PostalSnackTone.error);
    } finally {
      if (mounted) setState(() => _avatarBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(mockSessionProvider).user;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileEditTitle)),
      body: SafeArea(
        child: _loadingMe
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                children: [
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: PostalTokens.kraftBrown, width: 1.4),
                              ),
                              child: ClipOval(
                                child: _avatarPreviewBytes != null
                                    ? Image.memory(
                                        _avatarPreviewBytes!,
                                        width: 96,
                                        height: 96,
                                        fit: BoxFit.cover,
                                      )
                                    : PostalAvatar(
                                        name: user.nickname,
                                        size: 96,
                                        imageUrl: user.avatarUrl,
                                        framed: false,
                                      ),
                              ),
                            ),
                            if (_avatarBusy)
                              const SizedBox(
                                width: 104,
                                height: 104,
                                child: Center(
                                  child: SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: _avatarBusy ? null : _onChangeAvatar,
                          icon: const Icon(Icons.photo_camera_outlined),
                          label: Text(l10n.profileAvatarChange),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  PostalTextField(controller: _nickname, label: l10n.profileNickname),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    // ignore: deprecated_member_use
                    value: _countryCode,
                    decoration: InputDecoration(labelText: l10n.profileCountry),
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
                    label: l10n.profileBio,
                    maxLines: 6,
                    minLines: 4,
                    showClearButton: false,
                  ),
                  const SizedBox(height: 14),
                  PostalButton(
                    label: l10n.profileSave,
                    busy: _saving,
                    onPressed: _saving ? null : () => _onSave(context),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _onSave(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
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
          l10n.profileMockUpdated,
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
          l10n.profileSaved,
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
