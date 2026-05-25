import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../app/theme/postal_tokens.dart';
import '../../core/api/api_exception.dart';
import '../../core/oss/oss_upload_service.dart';
import '../../widgets/postal/postal.dart';
import '../shell/main_shell.dart';
import 'post_providers.dart';
import 'postcard_image_crop_page.dart';
import 'post_wall_remote.dart';

class _PickedImage {
  _PickedImage({required this.backendRef, required this.previewBytes});

  /// 提交给后端的 objectKey 或可读 URL。
  final String backendRef;

  /// 本地预览（私有桶下 [backendRef] 可能无法被 Image.network 读取）。
  final Uint8List previewBytes;
}

class PostComposePage extends ConsumerStatefulWidget {
  const PostComposePage({super.key});

  @override
  ConsumerState<PostComposePage> createState() => _PostComposePageState();
}

class _PostComposePageState extends ConsumerState<PostComposePage> {
  static const int _maxImages = 9;

  final _content = TextEditingController();
  bool _busy = false;
  bool _uploadBusy = false;
  final List<_PickedImage> _images = <_PickedImage>[];

  @override
  void dispose() {
    _content.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final l10n = AppLocalizations.of(context)!;
    if (_images.length >= _maxImages) {
      PostalSnack.show(
        context,
        l10n.postComposeMaxImages('$_maxImages'),
        tone: PostalSnackTone.warning,
      );
      return;
    }
    final XFile? x;
    try {
      final picker = ImagePicker();
      x = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 88,
      );
    } on PlatformException catch (e) {
      if (!mounted) return;
      if (e.code == 'channel-error') {
        PostalSnack.show(
          context,
          l10n.postComposePickerChannelError,
          tone: PostalSnackTone.error,
        );
      } else {
        PostalSnack.show(
          context,
          e.message ?? e.code,
          tone: PostalSnackTone.error,
        );
      }
      return;
    }
    if (x == null) {
      return;
    }
    final rawBytes = await x.readAsBytes();
    if (!mounted) return;
    final cropped = await Navigator.of(context).push<Uint8List>(
      MaterialPageRoute<Uint8List>(
        fullscreenDialog: true,
        builder: (_) => PostcardImageCropPage(imageBytes: rawBytes),
      ),
    );
    if (cropped == null || !mounted) {
      return;
    }
    setState(() => _uploadBusy = true);
    try {
      const ext = 'png';
      const ct = 'image/png';
      final url = await ref
          .read(ossUploadServiceProvider)
          .uploadPostcardImage(bytes: cropped, ext: ext, contentType: ct);
      if (!mounted) return;
      setState(
        () => _images.add(_PickedImage(backendRef: url, previewBytes: cropped)),
      );
      PostalSnack.show(
        context,
        l10n.postComposeImageUploaded,
        tone: PostalSnackTone.success,
      );
    } on ApiBusinessException catch (e) {
      if (mounted) {
        PostalSnack.show(context, e.message, tone: PostalSnackTone.error);
      }
    } finally {
      if (mounted) setState(() => _uploadBusy = false);
    }
  }

  Future<void> _publish() async {
    final l10n = AppLocalizations.of(context)!;
    if (_content.text.trim().isEmpty) {
      PostalSnack.show(
        context,
        l10n.postComposeNeedContent,
        tone: PostalSnackTone.warning,
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final refs = _images.map((e) => e.backendRef).toList();
      final created = await ref.read(postWallRemoteProvider).createPost(
            content: _content.text.trim(),
            imageUrls: refs.isEmpty ? null : refs,
          );
      ref.invalidate(postWallListProvider);
      if (!mounted) return;
      if (created.reviewStatus == 2) {
        final note = created.machineReviewNote;
        PostalSnack.show(
          context,
          note != null && note.isNotEmpty ? note : l10n.postComposeRejected,
          tone: PostalSnackTone.error,
        );
        return;
      }
      PostalSnack.show(
        context,
        l10n.postComposePublishedReal,
        tone: PostalSnackTone.success,
      );
      context.go(MainShellRoute.pathPostWall);
    } on ApiBusinessException catch (e) {
      if (mounted) {
        PostalSnack.show(context, e.message, tone: PostalSnackTone.error);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.postComposeTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          children: [
            PostalCardEnvelope(
              header: PostalSectionTitle(
                title: l10n.postComposeSectionTitle,
                subtitle: l10n.postComposeSectionSubtitle,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PostalTextField(
                    controller: _content,
                    label: l10n.postComposeContentLabel,
                    hint: l10n.postComposeContentHint,
                    maxLines: 8,
                    minLines: 6,
                    maxLength: 2000,
                    showClearButton: false,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 112,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Center(
                            child: Opacity(
                              opacity:
                                  (_busy ||
                                      _uploadBusy ||
                                      _images.length >= _maxImages)
                                  ? 0.45
                                  : 1,
                              child: Material(
                                color: PostalTokens.paperEnvelope,
                                shape: const CircleBorder(),
                                elevation: 1,
                                shadowColor: PostalTokens.inkNavy.withValues(
                                  alpha: 0.12,
                                ),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap:
                                      (_busy ||
                                          _uploadBusy ||
                                          _images.length >= _maxImages)
                                      ? null
                                      : _pickAndUploadImage,
                                  child: SizedBox(
                                    width: 72,
                                    height: 72,
                                    child: _uploadBusy
                                        ? const Padding(
                                            padding: EdgeInsets.all(18),
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.6,
                                            ),
                                          )
                                        : Icon(
                                            Icons.add_photo_alternate_outlined,
                                            size: 30,
                                            color: PostalTokens.postboxGreen
                                                .withValues(alpha: 0.9),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        ..._images.asMap().entries.map((e) {
                          final i = e.key;
                          final item = e.value;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: SizedBox(
                                    width: 132,
                                    height: 100,
                                    child: Image.memory(
                                      item.previewBytes,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Material(
                                    color: Colors.black54,
                                    shape: const CircleBorder(),
                                    child: IconButton(
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                        minWidth: 32,
                                        minHeight: 32,
                                      ),
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      onPressed: _busy || _uploadBusy
                                          ? null
                                          : () => setState(
                                              () => _images.removeAt(i),
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.postComposeMaxImages('$_maxImages'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: PostalTokens.inkSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  PostalButton(
                    label: l10n.postComposePublish,
                    onPressed: _busy ? null : _publish,
                    busy: _busy,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
