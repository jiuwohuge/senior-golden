import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../app/theme/postal_tokens.dart';
import '../../core/api/api_exception.dart';
import '../../core/bootstrap/app_bootstrap.dart';
import '../../core/session/app_session.dart';
import '../../core/oss/oss_upload_service.dart';
import '../../widgets/postal/postal.dart';
import '../auth/auth_repository.dart';
import 'avatar_crop_page.dart';

/// Normalize ISO country codes (uppercase, trim) for stable dropdown values.
String? _normalizeCountryCode(String? raw) {
  if (raw == null) return null;
  final t = raw.trim();
  if (t.isEmpty) return null;
  return t.toUpperCase();
}

class ProfileEditPage extends ConsumerStatefulWidget {
  const ProfileEditPage({super.key});

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  late final TextEditingController _nickname;
  late final TextEditingController _bio;
  String? _countryCode;
  int? _gender;
  bool _loadingMe = false;
  bool _saving = false;
  bool _avatarBusy = false;

  /// Cropped avatar bytes until user confirms upload.
  Uint8List? _avatarPendingBytes;

  @override
  void initState() {
    super.initState();
    final user = ref.read(appSessionProvider).user;
    _nickname = TextEditingController(text: user.nickname);
    _bio = TextEditingController(text: user.bio);
    _countryCode = _normalizeCountryCode(
      user.countryCode.isEmpty ? null : user.countryCode,
    );
    _gender = user.gender == 1 || user.gender == 2 ? user.gender : null;
    _loadingMe = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _pullMe());
  }

  Future<void> _pullMe() async {
    try {
      await ref.read(authRepositoryProvider).refreshSessionFromServer();
      if (!mounted) return;
      final u = ref.read(appSessionProvider).user;
      setState(() {
        _nickname.text = u.nickname;
        _bio.text = u.bio;
        _countryCode = _normalizeCountryCode(
          u.countryCode.isEmpty ? null : u.countryCode,
        );
        _avatarPendingBytes = null;
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

  Future<void> _onPickAvatar() async {
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
        PostalSnack.show(
          context,
          e.message ?? e.code,
          tone: PostalSnackTone.error,
        );
      }
      return;
    }
    if (x == null || !mounted) return;
    final raw = await x.readAsBytes();
    if (!mounted) return;
    final cropped = await Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(builder: (_) => AvatarCropPage(imageBytes: raw)),
    );
    if (cropped == null || !mounted) return;
    setState(() => _avatarPendingBytes = cropped);
  }

  void _discardPendingAvatar() {
    setState(() => _avatarPendingBytes = null);
  }

  Future<void> _confirmAvatarUpload() async {
    final pending = _avatarPendingBytes;
    if (pending == null || _avatarBusy) return;
    final l10n = AppLocalizations.of(context)!;

    setState(() => _avatarBusy = true);
    try {
      final key = await ref
          .read(ossUploadServiceProvider)
          .uploadAvatarImage(
            bytes: pending,
            ext: 'jpg',
            contentType: 'image/jpeg',
          );
      await ref
          .read(authRepositoryProvider)
          .updateProfileOnServer(
            nickname: _nickname.text.trim(),
            countryCode: _countryCode,
            bio: _bio.text,
            avatarUrl: key,
          );
      if (mounted) {
        setState(() => _avatarPendingBytes = null);
        PostalSnack.show(
          context,
          l10n.profileAvatarUploadPendingReview,
          tone: PostalSnackTone.success,
        );
      }
    } on ApiBusinessException catch (e) {
      if (mounted) {
        PostalSnack.show(
          context,
          e.message.isNotEmpty ? e.message : l10n.profileAvatarUploadFailed,
          tone: PostalSnackTone.error,
        );
      }
    } catch (_) {
      if (mounted) {
        PostalSnack.show(
          context,
          l10n.profileAvatarUploadFailed,
          tone: PostalSnackTone.error,
        );
      }
    } finally {
      if (mounted) setState(() => _avatarBusy = false);
    }
  }

  List<DropdownMenuItem<String>> _countryDropdownItems(
    List<CountryItem> countries,
    String languageCode,
  ) {
    final firstByNorm = <String, CountryItem>{};
    for (final c in countries) {
      if (c.code.isEmpty) continue;
      final k = c.code.trim().toUpperCase();
      firstByNorm.putIfAbsent(k, () => c);
    }
    final items = firstByNorm.entries
        .map(
          (e) => DropdownMenuItem<String>(
            value: e.key,
            child: Text(
              '${e.value.displayName(languageCode)} (${e.key})',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        )
        .toList();
    final cc = _countryCode;
    if (cc != null && cc.isNotEmpty && !firstByNorm.containsKey(cc)) {
      items.insert(
        0,
        DropdownMenuItem<String>(
          value: cc,
          child: Text(
            '$cc (${languageCode.startsWith('zh') ? '??????????' : 'from profile'})',
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }
    return items;
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations l10n) {
    final busy = _saving || _avatarBusy;
    return AppBar(
      // 与正文同为纸感浅色底 + 深色前景，避免「白字叠奶油底」不可读；与全站邮筒绿点缀统一。
      backgroundColor: PostalTokens.paperEnvelope,
      foregroundColor: PostalTokens.inkNavy,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      iconTheme: IconThemeData(color: PostalTokens.postboxGreen, size: 24),
      leading: IconButton(
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        onPressed: busy ? null : () => Navigator.of(context).maybePop(),
        icon: Icon(
          Icons.arrow_back_rounded,
          color: busy
              ? PostalTokens.postboxGreen.withValues(alpha: 0.35)
              : PostalTokens.postboxGreen,
        ),
      ),
      title: Text(
        l10n.profileEditTitle,
        style: TextStyle(
          color: PostalTokens.inkNavy,
          fontWeight: FontWeight.w800,
          fontSize: 20,
          letterSpacing: 0.2,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: PostalTokens.perforationLine.withValues(alpha: 0.9),
        ),
      ),
      actions: [
        TextButton(
          onPressed: busy ? null : () => Navigator.of(context).maybePop(),
          child: Text(
            l10n.profileEditCancel,
            style: TextStyle(
              color: busy
                  ? PostalTokens.postboxGreen.withValues(alpha: 0.4)
                  : PostalTokens.postboxGreen,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final user = ref.watch(appSessionProvider).user;
    final bootstrapAsync = ref.watch(appBootstrapProvider(locale.languageCode));
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: PostalTokens.paperCream,
      appBar: _buildAppBar(l10n),
      body: SafeArea(
        child: _loadingMe
            ? const Center(child: CircularProgressIndicator())
            : bootstrapAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => PostalEmptyState(
                  title: l10n.authBootstrapLoadFailed,
                  subtitle: bootstrapDebugErrorHint(err),
                  actionLabel: l10n.authRetry,
                  onAction: () =>
                      ref.invalidate(appBootstrapProvider(locale.languageCode)),
                  tone: PostalEmptyTone.error,
                ),
                data: (bootstrap) => ListView(
                  padding: EdgeInsets.fromLTRB(20, 18, 20, 24 + bottomInset),
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: PostalTokens.shadowSoft,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: PostalTokens.postboxGreen
                                          .withValues(alpha: 0.35),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: PostalTokens.kraftBrown,
                                        width: 1.35,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: _avatarPendingBytes != null
                                          ? Image.memory(
                                              _avatarPendingBytes!,
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            )
                                          : PostalAvatar(
                                              name: user.nickname,
                                              size: 100,
                                              imageUrl: user.avatarUrl,
                                              framed: false,
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              if (_avatarBusy)
                                Container(
                                  width: 116,
                                  height: 116,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black.withValues(alpha: 0.38),
                                  ),
                                  child: const Center(
                                    child: SizedBox(
                                      width: 32,
                                      height: 32,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        _ProfilePhotoPickButton(
                          label: l10n.profileAvatarChange,
                          enabled: !_avatarBusy && !_saving,
                          onPressed: _onPickAvatar,
                        ),
                      ],
                    ),
                    if (_avatarPendingBytes != null) ...[
                      const SizedBox(height: 16),
                      PostalCardEnvelope(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  color: PostalTokens.postboxGreen,
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    l10n.profileAvatarPreviewHint,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: PostalTokens.inkSecondary,
                                          height: 1.45,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            PostalButton(
                              label: l10n.profileAvatarConfirmUpload,
                              icon: Icons.cloud_upload_outlined,
                              busy: _avatarBusy,
                              onPressed: _avatarBusy
                                  ? null
                                  : _confirmAvatarUpload,
                            ),
                            const SizedBox(height: 10),
                            PostalButton(
                              label: l10n.profileAvatarDiscardUpload,
                              variant: PostalButtonVariant.ghost,
                              busy: false,
                              onPressed: _avatarBusy
                                  ? null
                                  : _discardPendingAvatar,
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    PostalTextField(
                      controller: _nickname,
                      label: l10n.profileNickname,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.authGenderLabel,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        FilterChip(
                          label: Text(l10n.authGenderMale),
                          selected: _gender == 1,
                          onSelected: _saving
                              ? null
                              : (_) => setState(() => _gender = 1),
                        ),
                        FilterChip(
                          label: Text(l10n.authGenderFemale),
                          selected: _gender == 2,
                          onSelected: _saving
                              ? null
                              : (_) => setState(() => _gender = 2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      // ignore: deprecated_member_use
                      value: _countryCode == null || _countryCode!.isEmpty
                          ? null
                          : _countryCode,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: l10n.profileCountry,
                      ),
                      items: _countryDropdownItems(
                        bootstrap.countries,
                        locale.languageCode,
                      ),
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
                    const SizedBox(height: 20),
                    PostalButton(
                      label: l10n.profileSave,
                      icon: Icons.save_outlined,
                      busy: _saving,
                      onPressed: _saving
                          ? null
                          : () => _onSave(context, bootstrap.countries),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _onSave(
    BuildContext context,
    List<CountryItem> countries,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    String? countryName;
    if (_countryCode != null && _countryCode!.isNotEmpty) {
      for (final c in countries) {
        if (c.code.trim().toUpperCase() == _countryCode) {
          countryName = c.nameEn;
          break;
        }
      }
      countryName ??= _countryCode;
    }
    setState(() => _saving = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .updateProfileOnServer(
            nickname: _nickname.text.trim(),
            countryCode: _countryCode,
            bio: _bio.text,
            gender: _gender,
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

/// 资料页头像入口：邮筒绿填充浅底 + 圆角胶囊 + `add_photo` 图标，与邮政主色一致且比细描边 secondary 更易识别。
class _ProfilePhotoPickButton extends StatelessWidget {
  const _ProfilePhotoPickButton({
    required this.label,
    required this.onPressed,
    required this.enabled,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onTap = enabled ? onPressed : null;
    return Material(
      color: PostalTokens.postboxGreen.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(26),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: PostalTokens.postboxGreen.withValues(alpha: 0.14),
        highlightColor: PostalTokens.postboxGreen.withValues(alpha: 0.06),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: enabled
                  ? PostalTokens.postboxGreen
                  : PostalTokens.postboxGreen.withValues(alpha: 0.38),
              width: 1.35,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate_rounded,
                  size: 23,
                  color: enabled
                      ? PostalTokens.postboxGreen
                      : PostalTokens.postboxGreen.withValues(alpha: 0.45),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: enabled
                          ? PostalTokens.postboxGreen
                          : PostalTokens.postboxGreen.withValues(alpha: 0.45),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
