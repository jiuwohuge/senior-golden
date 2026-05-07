import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/api/api_exception.dart';
import '../../core/env/app_env.dart';
import '../../core/mock/mock_repository.dart';
import 'post_providers.dart';
import 'post_wall_remote.dart';
import '../../core/oss/oss_upload_service.dart';
import '../../widgets/postal/postal.dart';
import '../shell/main_shell.dart';

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
  final List<String> _imageUrls = <String>[];

  @override
  void dispose() {
    _content.dispose();
    super.dispose();
  }

  String _extFromName(String name) {
    final i = name.lastIndexOf('.');
    if (i < 0 || i == name.length - 1) {
      return 'jpg';
    }
    return name.substring(i + 1).toLowerCase();
  }

  String _contentTypeForExt(String ext) {
    return switch (ext) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      _ => 'image/jpeg',
    };
  }

  Future<void> _pickAndUploadImage() async {
    if (_imageUrls.length >= _maxImages) {
      PostalSnack.show(context, '最多 $_maxImages 张配图', tone: PostalSnackTone.warning);
      return;
    }
    if (AppEnv.useMock) {
      if (!mounted) return;
      PostalSnack.show(
        context,
        'OSS 上传需关闭 Mock：flutter run --dart-define=USE_MOCK=false ...',
        tone: PostalSnackTone.info,
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
          '相册插件通道未连接。请完全停止应用后重新运行；仍失败请执行 flutter clean 再构建。',
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
    setState(() => _uploadBusy = true);
    try {
      final bytes = await x.readAsBytes();
      final ext = _extFromName(x.name);
      final ct = _contentTypeForExt(ext);
      final url = await ref.read(ossUploadServiceProvider).uploadPostcardImage(
            bytes: bytes,
            ext: ext,
            contentType: ct,
          );
      if (!mounted) return;
      setState(() => _imageUrls.add(url));
      PostalSnack.show(context, 'Image uploaded', tone: PostalSnackTone.success);
    } on ApiBusinessException catch (e) {
      if (mounted) {
        PostalSnack.show(context, e.message, tone: PostalSnackTone.error);
      }
    } finally {
      if (mounted) setState(() => _uploadBusy = false);
    }
  }

  Future<void> _publish() async {
    if (_content.text.trim().isEmpty) {
      PostalSnack.show(context, 'Please write something first.', tone: PostalSnackTone.warning);
      return;
    }
    setState(() => _busy = true);
    try {
      if (AppEnv.useMock) {
        await ref.read(mockPostsRepositoryProvider).publish(
              _content.text.trim(),
              imageUrls: _imageUrls.isEmpty ? null : List<String>.from(_imageUrls),
            );
      } else {
        await ref.read(postWallRemoteProvider).createPost(
              content: _content.text.trim(),
              imageUrls: _imageUrls.isEmpty ? null : List<String>.from(_imageUrls),
            );
      }
      ref.invalidate(postWallListProvider);
      if (!mounted) return;
      PostalSnack.show(
        context,
        AppEnv.useMock
            ? 'Mock: postcard published (+1 stamp)'
            : '已提交审核，审核通过后将出现在明信片墙',
        tone: PostalSnackTone.success,
      );
      context.go(MainShellRoute.pathPostWall);
    } on ApiBusinessException catch (e) {
      if (mounted) PostalSnack.show(context, e.message, tone: PostalSnackTone.error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Write postcard')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          children: [
            PostalCardEnvelope(
              header: const PostalSectionTitle(
                title: 'Compose',
                subtitle: 'Write one postcard for today',
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PostalTextField(
                    controller: _content,
                    label: 'Postcard content',
                    hint: 'Write your day, thoughts, or greetings...',
                    maxLines: 8,
                    minLines: 6,
                    maxLength: 2000,
                    showClearButton: false,
                  ),
                  const SizedBox(height: 12),
                  if (_imageUrls.isNotEmpty) ...[
                    SizedBox(
                      height: 108,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _imageUrls.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (_, i) {
                          final u = _imageUrls[i];
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  width: 140,
                                  height: 100,
                                  child: Image.network(
                                    u,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const ColoredBox(
                                      color: Color(0xFFE8E4DC),
                                      child: Center(child: Icon(Icons.broken_image_outlined)),
                                    ),
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
                                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                    icon: const Icon(Icons.close, color: Colors.white, size: 18),
                                    onPressed: _busy || _uploadBusy
                                        ? null
                                        : () => setState(() => _imageUrls.removeAt(i)),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  PostalButton(
                    label: _uploadBusy
                        ? 'Uploading…'
                        : (_imageUrls.isEmpty
                            ? 'Add image (OSS)'
                            : 'Add another (${_imageUrls.length}/$_maxImages)'),
                    onPressed: (_busy || _uploadBusy || _imageUrls.length >= _maxImages)
                        ? null
                        : _pickAndUploadImage,
                    busy: _uploadBusy,
                    variant: PostalButtonVariant.secondary,
                  ),
                  const SizedBox(height: 14),
                  PostalButton(
                    label: 'Publish now',
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
