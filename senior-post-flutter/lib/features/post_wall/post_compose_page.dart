import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_exception.dart';
import '../../core/mock/mock_repository.dart';
import '../../widgets/postal/postal.dart';
import '../shell/main_shell.dart';
import 'post_wall_page.dart';

class PostComposePage extends ConsumerStatefulWidget {
  const PostComposePage({super.key});

  @override
  ConsumerState<PostComposePage> createState() => _PostComposePageState();
}

class _PostComposePageState extends ConsumerState<PostComposePage> {
  final _content = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _content.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    if (_content.text.trim().isEmpty) {
      PostalSnack.show(context, 'Please write something first.', tone: PostalSnackTone.warning);
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(mockPostsRepositoryProvider).publish(_content.text.trim());
      ref.invalidate(postWallListProvider);
      if (!mounted) return;
      PostalSnack.show(context, 'Mock: postcard published (+1 stamp)', tone: PostalSnackTone.success);
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
                    maxLength: 500,
                    showClearButton: false,
                  ),
                  const SizedBox(height: 12),
                  PostalButton(
                    label: 'Add image (coming with OSS integration)',
                    onPressed: () {
                      PostalSnack.show(
                        context,
                        'Image upload will be connected in OSS integration stage.',
                        tone: PostalSnackTone.info,
                      );
                    },
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
