import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimAdvancedMsgListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/message_elem_type.dart';
import 'package:tencent_cloud_chat_sdk/enum/message_status.dart';
import 'package:tencent_cloud_chat_sdk/manager/v2_tim_manager.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart';

import '../../app/theme/postal_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../core/api/api_exception.dart';
import '../../core/session/app_session.dart';
import '../../widgets/postal/postal.dart';
import 'chat_composer_bar.dart';
import 'chat_im_support.dart';
import 'chat_senior_emojis.dart';
import 'im_unread_providers.dart';
import 'im_user_id.dart';
import 'mailbox_remote.dart';
import 'tim_facade.dart';

/// C2C 聊天（自研气泡 + 邮政主题），消息走腾讯 IM SDK。
class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({
    super.key,
    required this.peerUserId,
    this.displayName,
    this.peerAvatarUrl,
    this.trustedFriendship = false,
  });
  final String peerUserId;
  final String? displayName;
  final String? peerAvatarUrl;

  /// Connections / 已建立笔友关系的入口为 true，跳过 friendship-active 与主动 sync。
  final bool trustedFriendship;

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _scroll = ScrollController();
  final _input = TextEditingController();
  late final ValueNotifier<V2TimMessage?> _sentMessageSink;
  bool _busy = false;

  String? get _imPeerId => normalizeImUserId(widget.peerUserId);

  @override
  void initState() {
    super.initState();
    _sentMessageSink = ValueNotifier<V2TimMessage?>(null);
  }

  @override
  void dispose() {
    _sentMessageSink.dispose();
    _scroll.dispose();
    _input.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    final peerId = _imPeerId;
    if (peerId == null) {
      if (mounted) {
        PostalSnack.show(
          context,
          'Cannot send: invalid friend user id.',
          tone: PostalSnackTone.error,
        );
      }
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(seniorPostTimFacadeProvider).ensureLoggedIn();
      final tim = V2TIMManager();
      final created = await tim.v2TIMMessageManager.createTextMessage(
        text: text,
      );
      if (created.code != 0) {
        throw ApiBusinessException(created.code, created.desc);
      }
      final msg = created.data?.messageInfo;
      if (msg == null) {
        throw ApiBusinessException(0, 'Failed to create message');
      }
      final send = await sendC2cTextWithRecovery(
        ref: ref,
        peerUserId: peerId,
        message: msg,
      );
      if (send.code != 0) {
        throw ApiBusinessException(send.code, send.desc);
      }
      final delivered = send.data;
      if (delivered != null) {
        _sentMessageSink.value = delivered;
      }
      _input.clear();
    } on ApiBusinessException catch (e) {
      if (mounted) {
        PostalSnack.show(context, e.message, tone: PostalSnackTone.error);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _openEmojiPicker() {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: PostalTokens.paperEnvelope,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottomInset * 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.chatEmojiPickerTitle,
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                  color: PostalTokens.inkNavy,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.chatEmojiPickerSubtitle,
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                  color: PostalTokens.inkSecondary,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 220,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: kSeniorFriendlyEmojis.length,
                  itemBuilder: (_, i) {
                    final e = kSeniorFriendlyEmojis[i];
                    return Material(
                      color: PostalTokens.paperCard,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          _input.text = '${_input.text}$e';
                          _input.selection = TextSelection.collapsed(
                            offset: _input.text.length,
                          );
                          Navigator.of(ctx).pop();
                        },
                        child: Center(
                          child: Text(e, style: const TextStyle(fontSize: 30)),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.displayName ?? widget.peerUserId;
    final textTheme = Theme.of(context).textTheme;
    final imPeerId = _imPeerId;
    if (imPeerId == null) {
      return Scaffold(
        backgroundColor: PostalTokens.paperCream,
        appBar: AppBar(
          title: Text(title),
          backgroundColor: PostalTokens.postboxGreen,
          foregroundColor: Colors.white,
        ),
        body: const PostalEmptyState(
          title: 'Chat unavailable',
          subtitle: 'Invalid friend user id from server.',
          tone: PostalEmptyTone.error,
        ),
      );
    }
    return Scaffold(
      backgroundColor: PostalTokens.paperCream,
      appBar: AppBar(
        title: Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: PostalTokens.postboxGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          const PostalPerforationStrip(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: PostalTokens.paperEnvelope.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: PostalTokens.kraftBrown.withValues(alpha: 0.28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: PostalTokens.inkNavy.withValues(alpha: 0.04),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: PostalTokens.postboxGreen.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.markunread_mailbox_outlined,
                        size: 20,
                        color: PostalTokens.postboxGreen.withValues(
                          alpha: 0.85,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Postal chat — letters stay in Archive; here is for quick notes.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: PostalTokens.inkSecondary,
                          height: 1.45,
                        ),
                      ),
                    ),
                    IgnorePointer(
                      child: PostmarkRing(
                        size: 34,
                        strokeWidth: 1.2,
                        color: PostalTokens.stampVermilion.withValues(
                          alpha: 0.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: PostalChatBackground(
              child: _CloudChatBody(
                imPeerId: imPeerId,
                trustedFriendship: widget.trustedFriendship,
                peerDisplayName: widget.displayName,
                peerAvatarUrl: widget.peerAvatarUrl,
                scrollController: _scroll,
                sentMessageSink: _sentMessageSink,
              ),
            ),
          ),
          ChatComposerBar(
            controller: _input,
            busy: _busy,
            onSend: _busy ? null : _send,
            onEmojiTap: _busy ? null : _openEmojiPicker,
          ),
        ],
      ),
    );
  }
}

class _Bubble {
  _Bubble({
    required this.text,
    required this.incoming,
    required this.isSystem,
    this.sendStatus,
  });
  final String text;
  final bool incoming;
  final bool isSystem;

  /// 仅发出消息：[MessageStatus] 取值，用于静默展示送达态。
  final int? sendStatus;
}

class _BubbleTile extends StatelessWidget {
  const _BubbleTile({
    required this.bubble,
    required this.avatarImageUrl,
    required this.avatarName,
  });
  final _Bubble bubble;

  /// 本条消息旁展示的发送方头像（OSS URL 或 TIM faceUrl）。
  final String? avatarImageUrl;

  /// 头像占位首字母用。
  final String avatarName;

  @override
  Widget build(BuildContext context) {
    if (bubble.isSystem) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: PostalTokens.paperCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: PostalTokens.kraftBrown.withValues(alpha: 0.35),
              ),
            ),
            child: Text(
              bubble.text,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: PostalTokens.inkSecondary),
            ),
          ),
        ),
      );
    }
    final align = bubble.incoming
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.end;
    final bg = bubble.incoming
        ? PostalTokens.paperEnvelope
        : PostalTokens.postboxGreen;
    final fg = bubble.incoming ? PostalTokens.inkNavy : Colors.white;
    final border = Border.all(
      color: PostalTokens.postboxGreen.withValues(
        alpha: bubble.incoming ? 0.25 : 0.0,
      ),
    );
    final sending = bubble.sendStatus == MessageStatus.V2TIM_MSG_STATUS_SENDING;
    final failed =
        bubble.sendStatus == MessageStatus.V2TIM_MSG_STATUS_SEND_FAIL;
    final maxBubbleW = MediaQuery.sizeOf(context).width * 0.72;
    const avatarSize = 42.0;
    final bubbleRadius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(bubble.incoming ? 6 : 18),
      bottomRight: Radius.circular(bubble.incoming ? 18 : 6),
    );
    final bubbleCard = Container(
      constraints: BoxConstraints(maxWidth: maxBubbleW),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: bubbleRadius,
        border: border,
        boxShadow: [
          BoxShadow(
            color: PostalTokens.inkNavy.withValues(
              alpha: bubble.incoming ? 0.06 : 0.12,
            ),
            offset: const Offset(0, 3),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Text(
            bubble.text,
            style: TextStyle(color: fg, height: 1.4, fontSize: 16),
          ),
          // 暂不展示「已送达/已读」双勾，仅保留发送中与失败提示。
          if (!bubble.incoming && (sending || failed)) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (sending)
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                if (failed)
                  Icon(
                    Icons.error_outline_rounded,
                    size: 17,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
    final avatar = PostalAvatar(
      name: avatarName,
      size: avatarSize,
      imageUrl: avatarImageUrl,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: bubble.incoming
            ? <Widget>[
                avatar,
                const SizedBox(width: 10),
                bubbleCard,
                const Spacer(),
              ]
            : <Widget>[
                const Spacer(),
                bubbleCard,
                const SizedBox(width: 10),
                avatar,
              ],
      ),
    );
  }
}

class _CloudChatBody extends ConsumerStatefulWidget {
  const _CloudChatBody({
    required this.imPeerId,
    required this.scrollController,
    required this.sentMessageSink,
    this.trustedFriendship = false,
    this.peerDisplayName,
    this.peerAvatarUrl,
  });
  final String imPeerId;
  final bool trustedFriendship;
  final String? peerDisplayName;
  final String? peerAvatarUrl;
  final ScrollController scrollController;
  final ValueNotifier<V2TimMessage?> sentMessageSink;

  @override
  ConsumerState<_CloudChatBody> createState() => _CloudChatBodyState();
}

class _CloudChatBodyState extends ConsumerState<_CloudChatBody> {
  List<V2TimMessage> _items = const [];
  final Set<String> _seenMsgIds = {};
  String _selfId = '';
  bool _loading = true;
  String? _loadError;
  V2TimAdvancedMsgListener? _msgListener;

  @override
  void initState() {
    super.initState();
    widget.sentMessageSink.addListener(_onSentFromComposer);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    widget.sentMessageSink.removeListener(_onSentFromComposer);
    final l = _msgListener;
    _msgListener = null;
    if (l != null) {
      V2TIMManager().v2TIMMessageManager.removeAdvancedMsgListener(listener: l);
    }
    super.dispose();
  }

  void _onSentFromComposer() {
    final m = widget.sentMessageSink.value;
    if (m != null) {
      _ingestLiveMessage(m);
    }
  }

  bool _isPeerC2C(V2TimMessage m) {
    final gid = m.groupID;
    if (gid != null && gid.isNotEmpty) {
      return false;
    }
    return m.userID == widget.imPeerId;
  }

  void _ingestLiveMessage(V2TimMessage m) {
    if (!_isPeerC2C(m)) {
      return;
    }
    final id = m.msgID;
    if (id != null && id.isNotEmpty) {
      if (_seenMsgIds.contains(id)) {
        return;
      }
      _seenMsgIds.add(id);
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _loading = false;
      _loadError = null;
      _items = [..._items, m]
        ..sort((a, b) => (a.timestamp ?? 0).compareTo(b.timestamp ?? 0));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.scrollController.hasClients) {
        return;
      }
      widget.scrollController.jumpTo(
        widget.scrollController.position.maxScrollExtent,
      );
    });
    if (_selfId.isNotEmpty && m.sender != null && m.sender != _selfId) {
      unawaited(_markConversationReadOnServer());
    }
  }

  Future<void> _markConversationReadOnServer() async {
    final tim = V2TIMManager();
    // ignore: deprecated_member_use
    final r = await tim.v2TIMMessageManager.markC2CMessageAsRead(
      userID: widget.imPeerId,
    );
    if (r.code == 0 && mounted) {
      ref.read(imC2cUnreadProvider.notifier).clearPeer(widget.imPeerId);
    }
  }

  Future<void> _attachMsgListener() async {
    if (_msgListener != null) {
      return;
    }
    final listener = V2TimAdvancedMsgListener(
      onRecvNewMessage: (msg) {
        if (mounted) {
          _ingestLiveMessage(msg);
        }
      },
    );
    _msgListener = listener;
    await V2TIMManager().v2TIMMessageManager.addAdvancedMsgListener(
      listener: listener,
    );
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      if (!widget.trustedFriendship) {
        final repo = ref.read(mailboxRemoteRepositoryProvider);
        final canChat = await repo.isFriendshipActive(widget.imPeerId);
        if (!canChat) {
          if (!mounted) return;
          setState(() {
            _loading = false;
            _loadError =
                'Live chat is only for postal friends in Connections. Accept a delivered letter to add someone first.';
            _items = const [];
          });
          return;
        }
      }

      final r = await loadC2cHistoryWithRecovery(
        ref: ref,
        peerUserId: widget.imPeerId,
      );
      if (!mounted) return;
      if (r.code != 0) {
        setState(() {
          _loading = false;
          _loadError = 'Load history failed: ${r.desc}';
          _items = const [];
        });
        return;
      }
      final tim = V2TIMManager();
      final me = await tim.getLoginUser();
      final list = r.data != null
          ? List<V2TimMessage>.from(r.data!)
          : <V2TimMessage>[];
      list.sort((a, b) => (a.timestamp ?? 0).compareTo(b.timestamp ?? 0));
      _seenMsgIds
        ..clear()
        ..addAll(
          list
              .map((e) => e.msgID)
              .whereType<String>()
              .where((e) => e.isNotEmpty),
        );
      setState(() {
        _loading = false;
        _loadError = null;
        _selfId = me.data ?? '';
        _items = list;
      });
      await _attachMsgListener();
      // ignore: deprecated_member_use
      final read = await tim.v2TIMMessageManager.markC2CMessageAsRead(
        userID: widget.imPeerId,
      );
      if (read.code == 0 && mounted) {
        ref.read(imC2cUnreadProvider.notifier).clearPeer(widget.imPeerId);
      }
    } on ApiBusinessException catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadError = e.message;
          _items = const [];
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadError = '$e';
          _items = const [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadError != null) {
      return PostalEmptyState(
        title: 'Chat unavailable',
        subtitle: _loadError!,
        tone: PostalEmptyTone.error,
        actionLabel: AppLocalizations.of(context)!.commonRetry,
        onAction: _load,
      );
    }
    if (_items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.mark_chat_unread_outlined,
                size: 56,
                color: PostalTokens.postboxGreen.withValues(alpha: 0.45),
              ),
              const SizedBox(height: 16),
              Text(
                'No messages yet',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: PostalTokens.inkNavy,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Say hello — your note will appear here right away.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: PostalTokens.inkSecondary,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      );
    }
    final session = ref.watch(appSessionProvider);
    final selfName = session.user.nickname.trim().isEmpty
        ? 'Me'
        : session.user.nickname.trim();
    final selfAvatar = session.user.avatarUrl;
    final peerName = (widget.peerDisplayName ?? widget.imPeerId).trim();
    return ListView.builder(
      controller: widget.scrollController,
      padding: const EdgeInsets.fromLTRB(14, 20, 14, 24),
      itemCount: _items.length,
      itemBuilder: (_, i) {
        final m = _items[i];
        final incoming = m.sender != _selfId;
        String text = '';
        if (m.elemType == MessageElemType.V2TIM_ELEM_TYPE_TEXT &&
            m.textElem != null) {
          text = m.textElem!.text ?? '';
        }
        final timFace = m.faceUrl?.trim();
        final timFaceOk = timFace != null && timFace.isNotEmpty;
        final avatarUrl = incoming
            ? (timFaceOk ? timFace : widget.peerAvatarUrl)
            : (timFaceOk ? timFace : selfAvatar);
        final avatarLabel = incoming
            ? (m.nickName?.trim().isNotEmpty == true
                  ? m.nickName!.trim()
                  : peerName)
            : selfName;
        return _BubbleTile(
          avatarImageUrl: avatarUrl,
          avatarName: avatarLabel,
          bubble: _Bubble(
            text: text.isEmpty ? '(unsupported)' : text,
            incoming: incoming,
            isSystem: false,
            sendStatus: incoming ? null : m.status,
          ),
        );
      },
    );
  }
}
