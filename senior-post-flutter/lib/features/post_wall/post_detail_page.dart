import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../app/theme/postal_tokens.dart';
import '../../core/api/api_exception.dart';
import '../../core/models/domain_models.dart';
import '../../core/session/app_session.dart';
import '../../widgets/postal/postal.dart';
import '../../widgets/postal/postal_gender_icon.dart';
import 'post_providers.dart';
import 'post_wall_report_sheet.dart';
import 'post_wall_remote.dart';

void _showContentReport(
  BuildContext context, {
  required String targetType,
  required String objectId,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) =>
        PostWallReportSheet(targetType: targetType, objectId: objectId),
  );
}

class PostDetailPage extends ConsumerStatefulWidget {
  const PostDetailPage({super.key, required this.postId});
  final String postId;

  @override
  ConsumerState<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends ConsumerState<PostDetailPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        ref.invalidate(postDetailProvider(widget.postId));
        ref.invalidate(postCommentsProvider(widget.postId));
      });
    }
  }

  Future<void> _onRefresh() async {
    ref.invalidate(postDetailProvider(widget.postId));
    ref.invalidate(postCommentsProvider(widget.postId));
    await Future.wait([
      ref.read(postDetailProvider(widget.postId).future),
      ref.read(postCommentsProvider(widget.postId).future),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final postId = widget.postId;
    final postAsync = ref.watch(postDetailProvider(postId));
    final commentsAsync = ref.watch(postCommentsProvider(postId));
    final l10n = AppLocalizations.of(context)!;

    final meId = ref.watch(appSessionProvider).user.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.postDetailTitle),
        actions: [
          if (postAsync.valueOrNull != null &&
              meId != postAsync.valueOrNull!.author.id)
            IconButton(
              tooltip: 'Report',
              icon: const Icon(Icons.flag_outlined),
              onPressed: () => _showContentReport(
                context,
                targetType: 'postcard',
                objectId: postId,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: postAsync.when(
          loading: () =>
              const PostalSkeletonList(itemCount: 1, itemHeight: 220),
          error: (e, _) => PostalEmptyState(
            title: 'Unable to load postcard',
            subtitle: '$e',
            tone: PostalEmptyTone.error,
          ),
          data: (post) {
            if (post == null) {
              return const PostalEmptyState(
                title: 'Postcard not found',
                subtitle: 'This postcard may have been removed.',
              );
            }
            final review = post.reviewStatus;
            final String? reviewLabel = review == null
                ? null
                : switch (review) {
                    0 => l10n.postcardReviewPendingBanner,
                    2 => l10n.postcardReviewRejectedBanner,
                    _ => null,
                  };
            return Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                      children: [
                        if (reviewLabel != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: PostalTokens.stampVermilionMuted,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: PostalTokens.stampVermilion.withValues(
                                    alpha: 0.35,
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: PostalTokens.stampVermilion,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        reviewLabel,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        PostalCardEnvelope(
                          header: Row(
                            children: [
                              _ClickableUserAvatar(user: post.author, size: 42),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        post.author.nickname,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                DateFormat(
                                  'MM-dd HH:mm',
                                ).format(post.createdAt),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _WeChatTextBlock(content: post.content),
                              if (post.resolvedImageUrls.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                _WeChatPhotoGrid(
                                  imageUrls: post.resolvedImageUrls,
                                  onTapImage: (index) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => _PhotoViewerPage(
                                          imageUrls: post.resolvedImageUrls,
                                          initialIndex: index,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        PostalSectionTitle(title: 'Comments'),
                        const SizedBox(height: 10),
                        commentsAsync.when(
                          loading: () => const PostalSkeletonList(
                            itemCount: 3,
                            itemHeight: 86,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                          ),
                          error: (e, _) => PostalEmptyState(
                            title: 'Failed to load comments',
                            subtitle: '$e',
                            tone: PostalEmptyTone.error,
                          ),
                          data: (items) {
                            if (items.isEmpty) {
                              return const PostalEmptyState(
                                title: 'No comments yet',
                                subtitle: 'Start the first kind reply.',
                              );
                            }
                            return Column(
                              children: items
                                  .map(
                                    (c) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 10,
                                      ),
                                      child: PostalCardEnvelope(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                _ClickableUserAvatar(
                                                  user: c.author,
                                                  size: 34,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    c.author.nickname,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Text(
                                                  DateFormat(
                                                    'MM-dd HH:mm',
                                                  ).format(c.createdAt),
                                                ),
                                                if (meId != c.author.id)
                                                  IconButton(
                                                    tooltip: 'Report comment',
                                                    icon: const Icon(
                                                      Icons.flag_outlined,
                                                      size: 20,
                                                    ),
                                                    onPressed: () =>
                                                        _showContentReport(
                                                          context,
                                                          targetType: 'comment',
                                                          objectId: c.id,
                                                        ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(c.content),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                _CommentComposer(postId: postId),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ClickableUserAvatar extends StatelessWidget {
  const _ClickableUserAvatar({required this.user, required this.size});

  final AppUser user;
  final double size;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: () => context.push('/user/${user.id}'),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          PostalAvatar(
            name: user.nickname,
            size: size,
            imageUrl: user.avatarUrl,
          ),
          if (user.gender >= 1)
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: PostalTokens.perforationLine),
                ),
                alignment: Alignment.center,
                child: PostalGenderIcon(gender: user.gender, size: 10),
              ),
            ),
        ],
      ),
    );
  }
}

class _WeChatTextBlock extends StatefulWidget {
  const _WeChatTextBlock({required this.content});

  final String content;

  @override
  State<_WeChatTextBlock> createState() => _WeChatTextBlockState();
}

class _WeChatTextBlockState extends State<_WeChatTextBlock> {
  static const int _kCollapsedLines = 6;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(
      context,
    ).textTheme.bodyLarge?.copyWith(height: 1.55, color: PostalTokens.inkNavy);
    final isZh = Localizations.localeOf(context).languageCode.startsWith('zh');
    final moreLabel = isZh ? '全文' : 'Read more';
    final lessLabel = isZh ? '收起' : 'Collapse';

    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: widget.content, style: style),
          maxLines: _kCollapsedLines,
          textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth);
        final canExpand = painter.didExceedMaxLines;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.content,
              style: style,
              maxLines: _expanded ? null : _kCollapsedLines,
              overflow: _expanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
            ),
            if (canExpand) ...[
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () => setState(() => _expanded = !_expanded),
                  child: Text(
                    _expanded ? lessLabel : moreLabel,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: PostalTokens.postboxGreen,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _WeChatPhotoGrid extends StatelessWidget {
  const _WeChatPhotoGrid({required this.imageUrls, required this.onTapImage});

  final List<String> imageUrls;
  final ValueChanged<int> onTapImage;

  @override
  Widget build(BuildContext context) {
    final displayCount = imageUrls.length > 9 ? 9 : imageUrls.length;
    if (displayCount <= 0) {
      return const SizedBox.shrink();
    }
    if (displayCount == 1) {
      return _buildSingle(context, 0);
    }
    final crossAxisCount = switch (displayCount) {
      2 => 2,
      4 => 2,
      _ => 3,
    };
    const gap = 4.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileSize =
            (constraints.maxWidth - gap * (crossAxisCount - 1)) /
            crossAxisCount;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: List.generate(displayCount, (index) {
            final showMoreMask =
                imageUrls.length > 9 && index == displayCount - 1;
            return SizedBox(
              width: tileSize,
              height: tileSize,
              child: _buildTile(
                context,
                index,
                radius: BorderRadius.circular(6),
                showMoreMask: showMoreMask,
                moreCount: imageUrls.length - 9,
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildSingle(BuildContext context, int index) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () => onTapImage(index),
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: PostalOssNetworkImage(
            imageUrl: imageUrls[index],
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context,
    int index, {
    required BorderRadius radius,
    required bool showMoreMask,
    required int moreCount,
  }) {
    return ClipRRect(
      borderRadius: radius,
      child: InkWell(
        onTap: () => onTapImage(index),
        child: Stack(
          fit: StackFit.expand,
          children: [
            PostalOssNetworkImage(
              imageUrl: imageUrls[index],
              fit: BoxFit.cover,
            ),
            if (showMoreMask)
              ColoredBox(
                color: Colors.black45,
                child: Center(
                  child: Text(
                    '+$moreCount',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PhotoViewerPage extends StatefulWidget {
  const _PhotoViewerPage({required this.imageUrls, required this.initialIndex});

  final List<String> imageUrls;
  final int initialIndex;

  @override
  State<_PhotoViewerPage> createState() => _PhotoViewerPageState();
}

class _PhotoViewerPageState extends State<_PhotoViewerPage> {
  static const double _minScale = 1.0;
  static const double _maxScale = 3.0;

  late final PageController _pageController;
  late int _index;

  final Map<int, Offset> _activePointers = {};
  double _scale = 1.0;
  Offset _offset = Offset.zero;

  double _baseScale = 1.0;
  Offset _baseOffset = Offset.zero;
  double? _initialPinchDistance;
  Offset? _initialFocalPoint;

  bool get _isMultiTouch => _activePointers.length >= 2;
  bool get _isZoomed => _scale > 1.01;
  bool get _shouldLockPageScroll =>
      _isMultiTouch || (_isZoomed && _activePointers.isNotEmpty);

  void _resetZoom() {
    _scale = 1.0;
    _offset = Offset.zero;
    _initialPinchDistance = null;
    _initialFocalPoint = null;
  }

  void _handlePointerDown(PointerDownEvent event) {
    _activePointers[event.pointer] = event.position;
    if (_activePointers.length == 2) {
      _baseScale = _scale;
      _baseOffset = _offset;
      _initialPinchDistance = _computePinchDistance();
      _initialFocalPoint = _computeFocalPoint();
      setState(() {});
      return;
    }
    if (_activePointers.length == 1 && _isZoomed) {
      setState(() {});
    }
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (!_activePointers.containsKey(event.pointer)) {
      return;
    }
    _activePointers[event.pointer] = event.position;

    if (_activePointers.length >= 2) {
      final distance = _computePinchDistance();
      if (_initialPinchDistance == null ||
          _initialPinchDistance! < 1 ||
          _initialFocalPoint == null) {
        _initialPinchDistance = distance;
        _initialFocalPoint = _computeFocalPoint();
        _baseScale = _scale;
        _baseOffset = _offset;
        return;
      }

      final scaleFactor = distance / _initialPinchDistance!;
      final newScale = (_baseScale * scaleFactor).clamp(_minScale, _maxScale);
      final scaleChange = newScale / _baseScale;
      final focalDelta = _computeFocalPoint() - _initialFocalPoint!;
      final newOffset =
          _baseOffset * scaleChange + focalDelta * (1 - scaleChange);

      setState(() {
        _scale = newScale;
        _offset = newOffset;
      });
      return;
    }

    if (_activePointers.length == 1 && _isZoomed) {
      setState(() {
        _offset += event.delta;
      });
    }
  }

  void _handlePointerUp(PointerEvent event) {
    _activePointers.remove(event.pointer);

    if (_activePointers.isEmpty) {
      if (_scale <= 1.05) {
        _resetZoom();
      }
      setState(() {});
      return;
    }

    if (_activePointers.length < 2) {
      _initialPinchDistance = null;
      _initialFocalPoint = null;
      _baseScale = _scale;
      _baseOffset = _offset;
    }

    if (_activePointers.length == 1 && !_isZoomed) {
      setState(() {});
    }
  }

  double _computePinchDistance() {
    final points = _activePointers.values.toList(growable: false);
    if (points.length < 2) {
      return 0;
    }
    return (points[0] - points[1]).distance;
  }

  Offset _computeFocalPoint() {
    final points = _activePointers.values.toList(growable: false);
    if (points.isEmpty) {
      return Offset.zero;
    }
    if (points.length == 1) {
      return points[0];
    }
    return Offset(
      (points[0].dx + points[1].dx) / 2,
      (points[0].dy + points[1].dy) / 2,
    );
  }

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_index + 1}/${widget.imageUrls.length}'),
      ),
      body: Listener(
        onPointerDown: _handlePointerDown,
        onPointerMove: _handlePointerMove,
        onPointerUp: _handlePointerUp,
        onPointerCancel: _handlePointerUp,
        behavior: HitTestBehavior.translucent,
        child: PageView.builder(
          controller: _pageController,
          physics: _shouldLockPageScroll
              ? const NeverScrollableScrollPhysics()
              : const PageScrollPhysics(),
          itemCount: widget.imageUrls.length,
          onPageChanged: (value) {
            setState(() {
              _index = value;
              _activePointers.clear();
              _resetZoom();
            });
          },
          itemBuilder: (_, i) {
            final image = PostalOssNetworkImage(
              imageUrl: widget.imageUrls[i],
              fit: BoxFit.contain,
            );
            final applyTransform = i == _index && (_isZoomed || _isMultiTouch);
            if (!applyTransform) {
              return Center(child: image);
            }
            return Center(
              child: Transform(
                transform: Matrix4.identity()
                  ..translateByDouble(_offset.dx, _offset.dy, 0, 1)
                  ..scaleByDouble(_scale, _scale, _scale, 1),
                alignment: Alignment.center,
                child: image,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CommentComposer extends ConsumerStatefulWidget {
  const _CommentComposer({required this.postId});
  final String postId;

  @override
  ConsumerState<_CommentComposer> createState() => _CommentComposerState();
}

class _CommentComposerState extends ConsumerState<_CommentComposer> {
  final _commentCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context)!;
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) {
      PostalSnack.show(
        context,
        l10n.postDetailCommentRequired,
        tone: PostalSnackTone.warning,
      );
      return;
    }
    setState(() => _sending = true);
    try {
      await ref
          .read(postWallRemoteProvider)
          .createComment(postcardId: widget.postId, content: text);
      if (!mounted) return;
      _commentCtrl.clear();
      ref.invalidate(postCommentsProvider(widget.postId));
      ref.invalidate(postDetailProvider(widget.postId));
      PostalSnack.show(
        context,
        l10n.postDetailCommentPosted,
        tone: PostalSnackTone.success,
      );
    } on ApiBusinessException catch (e) {
      if (mounted) {
        PostalSnack.show(context, e.message, tone: PostalSnackTone.error);
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: PostalTextField(
              controller: _commentCtrl,
              label: 'Write a comment',
              showClearButton: true,
            ),
          ),
          const SizedBox(width: 8),
          // PostalButton expand needs bounded width inside Row.
          SizedBox(
            width: 96,
            child: PostalButton(
              label: 'Send',
              onPressed: _sending ? null : _send,
              busy: _sending,
              expand: true,
              minHeight: 52,
            ),
          ),
        ],
      ),
    );
  }
}
