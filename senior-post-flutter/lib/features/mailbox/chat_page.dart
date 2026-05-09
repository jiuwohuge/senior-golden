import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimAdvancedMsgListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/message_elem_type.dart';
import 'package:tencent_cloud_chat_sdk/enum/message_priority_enum.dart';
import 'package:tencent_cloud_chat_sdk/manager/v2_tim_manager.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart';

import '../../app/theme/postal_tokens.dart';
import '../../core/api/api_exception.dart';
import '../../widgets/postal/postal.dart';
import 'mailbox_remote.dart';
import 'tim_facade.dart';

/// C2C 聊天（自研气泡 + 邮政主题），消息走腾讯 IM SDK。
class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key, required this.peerUserId, this.displayName});
  final String peerUserId;
  final String? displayName;

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _scroll = ScrollController();
  final _input = TextEditingController();
  late final ValueNotifier<V2TimMessage?> _sentMessageSink;
  bool _busy = false;

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
    setState(() => _busy = true);
    try {
      final repo = ref.read(mailboxRemoteRepositoryProvider);
      final canChat = await repo.isFriendshipActive(widget.peerUserId);
      if (!canChat) {
        if (mounted) {
          PostalSnack.show(
            context,
            'Only postal friends in Connections can use live chat.',
            tone: PostalSnackTone.error,
          );
        }
        return;
      }
      await ref.read(seniorPostTimFacadeProvider).ensureLoggedIn();
      final tim = V2TIMManager();
      final created = await tim.v2TIMMessageManager.createTextMessage(
        text: text,
      );
      if (created.code != 0) {
        throw ApiBusinessException(created.code, created.desc);
      }
      final msg = created.data?.messageInfo;
      final send = await tim.v2TIMMessageManager.sendMessage(
        message: msg,
        receiver: widget.peerUserId,
        groupID: '',
        priority: MessagePriorityEnum.V2TIM_PRIORITY_NORMAL,
      );
      if (send.code != 0) {
        throw ApiBusinessException(send.code, send.desc);
      }
      final delivered = send.data;
      if (delivered != null) {
        _sentMessageSink.value = delivered;
      }
      _input.clear();
      if (mounted) {
        PostalSnack.show(context, 'Sent', tone: PostalSnackTone.success);
      }
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
    final title = widget.displayName ?? widget.peerUserId;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: PostalTokens.paperCream,
            child: Text(
              'Postal thread: letter history stays in Archive.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: PostalTokens.inkSecondary),
            ),
          ),
          Expanded(
            child: _CloudChatBody(
              peerUserId: widget.peerUserId,
              scrollController: _scroll,
              sentMessageSink: _sentMessageSink,
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: PostalTextField(
                      controller: _input,
                      label: 'Message',
                      maxLines: 4,
                      minLines: 1,
                      showClearButton: false,
                    ),
                  ),
                  const SizedBox(width: 10),
                  PostalButton(
                    label: 'Send',
                    expand: false,
                    busy: _busy,
                    onPressed: _busy ? null : _send,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble {
  _Bubble({required this.text, required this.incoming, required this.isSystem});
  final String text;
  final bool incoming;
  final bool isSystem;
}

class _BubbleTile extends StatelessWidget {
  const _BubbleTile({required this.bubble});
  final _Bubble bubble;

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
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 320),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
              border: border,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(bubble.text, style: TextStyle(color: fg, height: 1.35)),
          ),
        ],
      ),
    );
  }
}

class _CloudChatBody extends ConsumerStatefulWidget {
  const _CloudChatBody({
    required this.peerUserId,
    required this.scrollController,
    required this.sentMessageSink,
  });
  final String peerUserId;
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
    return m.userID == widget.peerUserId;
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
        ..sort(
          (a, b) => (a.timestamp ?? 0).compareTo(b.timestamp ?? 0),
        );
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.scrollController.hasClients) {
        return;
      }
      widget.scrollController.jumpTo(
        widget.scrollController.position.maxScrollExtent,
      );
    });
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
      final repo = ref.read(mailboxRemoteRepositoryProvider);
      final canChat = await repo.isFriendshipActive(widget.peerUserId);
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
      await ref.read(seniorPostTimFacadeProvider).ensureLoggedIn();
      final tim = V2TIMManager();
      final me = await tim.getLoginUser();
      final r = await tim.v2TIMMessageManager.getC2CHistoryMessageList(
        userID: widget.peerUserId,
        count: 30,
        lastMsg: null,
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
      final list = r.data != null
          ? List<V2TimMessage>.from(r.data!)
          : <V2TimMessage>[];
      list.sort(
        (a, b) => (a.timestamp ?? 0).compareTo(b.timestamp ?? 0),
      );
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
        actionLabel: 'Retry',
        onAction: _load,
      );
    }
    if (_items.isEmpty) {
      return const Center(child: Text('No messages yet'));
    }
    return ListView.builder(
      controller: widget.scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      itemCount: _items.length,
      itemBuilder: (_, i) {
        final m = _items[i];
        final incoming = m.sender != _selfId;
        String text = '';
        if (m.elemType == MessageElemType.V2TIM_ELEM_TYPE_TEXT &&
            m.textElem != null) {
          text = m.textElem!.text ?? '';
        }
        return _BubbleTile(
          bubble: _Bubble(
            text: text.isEmpty ? '(unsupported)' : text,
            incoming: incoming,
            isSystem: false,
          ),
        );
      },
    );
  }
}
