import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/oss/oss_get_sign_service.dart';
import '../../core/oss/oss_object_key_hint.dart';

/// Loads network images; when [enableResign] and first frame fails, tries one OSS resign.
class PostalOssNetworkImage extends ConsumerStatefulWidget {
  const PostalOssNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.alignment = Alignment.center,
    this.enableResign = true,
    this.errorBuilder,
  });

  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Alignment alignment;
  final bool enableResign;
  final Widget Function(BuildContext context)? errorBuilder;

  @override
  ConsumerState<PostalOssNetworkImage> createState() => _PostalOssNetworkImageState();
}

class _PostalOssNetworkImageState extends ConsumerState<PostalOssNetworkImage> {
  late String _displayUrl;
  bool _resignScheduled = false;

  @override
  void initState() {
    super.initState();
    _displayUrl = widget.imageUrl;
  }

  @override
  void didUpdateWidget(covariant PostalOssNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _displayUrl = widget.imageUrl;
      _resignScheduled = false;
    }
  }

  Future<void> _tryResignOnce(String objectKey) async {
    if (!mounted) {
      return;
    }
    try {
      final svc = ref.read(ossGetSignServiceProvider);
      final next = await svc.signedUrlForKey(objectKey);
      if (next != null && next.isNotEmpty && mounted) {
        setState(() => _displayUrl = next);
      }
    } catch (_) {
      // 保持 error UI；用户可下拉刷新列表换取服务端新签名。
    }
  }

  @override
  Widget build(BuildContext context) {
    return Image.network(
      _displayUrl,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      alignment: widget.alignment,
      errorBuilder: (ctx, _, __) {
        final allow = widget.enableResign && !_resignScheduled;
        if (allow) {
          final key = tryParseOssObjectKey(widget.imageUrl);
          if (key != null) {
            _resignScheduled = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _tryResignOnce(key);
            });
          }
        }
        return widget.errorBuilder?.call(ctx) ??
            const ColoredBox(
              color: Color(0xFFE8E4DC),
              child: Icon(Icons.broken_image_outlined),
            );
      },
    );
  }
}
