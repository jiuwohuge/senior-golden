import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/oss/oss_get_sign_service.dart';
import '../../core/oss/oss_object_key_hint.dart';

/// 稳定 `cacheKey`（objectKey 或去掉 query 的 URL path）+ 可选换签重试。
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
  ConsumerState<PostalOssNetworkImage> createState() =>
      _PostalOssNetworkImageState();
}

class _PostalOssNetworkImageState extends ConsumerState<PostalOssNetworkImage> {
  late String _displayUrl;
  bool _resignScheduled = false;

  static String _stableCacheKey(String originalUrl) {
    final k = tryParseOssObjectKey(originalUrl);
    if (k != null && k.isNotEmpty) {
      return k;
    }
    final u = Uri.tryParse(originalUrl.trim());
    if (u != null && u.hasScheme && u.host.isNotEmpty) {
      return '${u.scheme}://${u.host}${u.path}';
    }
    return originalUrl.trim();
  }

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
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final memW = widget.width != null ? (widget.width! * dpr).round() : null;
    final memH = widget.height != null ? (widget.height! * dpr).round() : null;

    return CachedNetworkImage(
      imageUrl: _displayUrl,
      cacheKey: _stableCacheKey(widget.imageUrl),
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      alignment: widget.alignment,
      memCacheWidth: memW,
      memCacheHeight: memH,
      errorWidget: (ctx, _, __) {
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
