import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_exception.dart';
import 'mock_data.dart';
import 'mock_delay.dart';
import 'mock_models.dart';

/// 当前用户 + 邮票余额 + VIP 状态的可变状态容器。
/// 让所有页面都能"消费"和"修改"同一份本地状态。
class MockSessionState {
  MockSessionState({
    required this.user,
    required this.stampBalance,
    required this.dailyStampCap,
  });

  final MockUser user;
  final int stampBalance;
  final int dailyStampCap;

  bool get isVip => user.isVip;

  MockSessionState copyWith({
    MockUser? user,
    int? stampBalance,
    int? dailyStampCap,
  }) {
    return MockSessionState(
      user: user ?? this.user,
      stampBalance: stampBalance ?? this.stampBalance,
      dailyStampCap: dailyStampCap ?? this.dailyStampCap,
    );
  }
}

class MockSessionNotifier extends StateNotifier<MockSessionState> {
  MockSessionNotifier()
    : super(
        MockSessionState(
          user: MockData.currentUser,
          stampBalance: 3,
          dailyStampCap: 3,
        ),
      );

  void updateProfile({
    String? nickname,
    String? bio,
    String? countryCode,
    String? countryName,
    List<String>? interests,
    List<int>? interestTagIds,
    String? avatarUrl,
  }) {
    state = state.copyWith(
      user: state.user.copyWith(
        nickname: nickname,
        bio: bio,
        countryCode: countryCode,
        countryName: countryName,
        interests: interests,
        interestTagIds: interestTagIds,
        avatarUrl: avatarUrl,
      ),
    );
  }

  /// 将后端 `AppPublicUserVO`（`/api/auth/me`、登录 user、PATCH profile）同步到本地展示态。
  void applyFromPublicUserVo(Map<String, dynamic> m) {
    final code = (m['countryCode'] as String?) ?? '';
    var nameEn = code;
    for (final c in MockData.countries) {
      if (c.code == code) {
        nameEn = c.nameEn;
        break;
      }
    }
    final uid = m['id'];
    final idStr = uid == null
        ? state.user.id
        : (uid is int ? '$uid' : (uid as num).toString());
    var interests = state.user.interests;
    final namesRaw = m['interestTagNames'];
    if (namesRaw is List<dynamic>) {
      interests = namesRaw
          .whereType<String>()
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    var interestTagIds = state.user.interestTagIds;
    final idsRaw = m['interestTagIds'];
    if (idsRaw is List<dynamic>) {
      interestTagIds = idsRaw.whereType<num>().map((n) => n.toInt()).toList();
    }
    state = state.copyWith(
      user: MockUser(
        id: idStr,
        nickname: (m['nickname'] as String?) ?? state.user.nickname,
        email: (m['email'] as String?) ?? state.user.email,
        countryCode: code,
        countryName: nameEn,
        birthYear: (m['birthYear'] as num?)?.toInt() ?? state.user.birthYear,
        bio: m['bio'] as String? ?? '',
        interests: interests,
        interestTagIds: interestTagIds,
        avatarUrl: m['avatarUrl'] as String?,
        isVip: m['isVip'] as bool? ?? state.user.isVip,
      ),
      stampBalance: (m['stampsBalance'] as num?)?.toInt() ?? state.stampBalance,
    );
  }

  /// 消耗邮票（挂号信、加速）；不足时抛业务异常。
  void consume(int amount) {
    if (state.isVip) return;
    if (state.stampBalance < amount) {
      throw ApiBusinessException(4001, 'Mock: Not enough stamps.');
    }
    state = state.copyWith(stampBalance: state.stampBalance - amount);
  }

  /// 奖励邮票（发帖、每日登录）。
  void grant(int amount) {
    state = state.copyWith(stampBalance: state.stampBalance + amount);
  }

  /// Mock 注册成功后写入新会话（与真接口返回的 `user` 字段语义接近）。
  void seedNewMockAccount({
    required String email,
    required String nickname,
    required int birthYear,
    required String countryCode,
    required String countryName,
    required List<String> interests,
  }) {
    state = MockSessionState(
      user: MockUser(
        id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
        nickname: nickname,
        email: email,
        countryCode: countryCode,
        countryName: countryName,
        birthYear: birthYear,
        bio: '',
        interests: interests,
        interestTagIds: const [],
        isVip: false,
      ),
      stampBalance: 3,
      dailyStampCap: 3,
    );
  }

  /// 切换 VIP（仅 Mock 演示）。
  void toggleVip() {
    final user = state.user;
    state = state.copyWith(
      user: MockUser(
        id: user.id,
        nickname: user.nickname,
        email: user.email,
        countryCode: user.countryCode,
        countryName: user.countryName,
        birthYear: user.birthYear,
        bio: user.bio,
        interests: user.interests,
        interestTagIds: user.interestTagIds,
        avatarUrl: user.avatarUrl,
        isVip: !user.isVip,
      ),
    );
  }
}

final mockSessionProvider =
    StateNotifierProvider<MockSessionNotifier, MockSessionState>((ref) {
      return MockSessionNotifier();
    });

/// Posts repository（明信片墙）：提供分页列表 + 评论 + 发布。
class MockPostsRepository {
  MockPostsRepository(this._ref);

  final Ref _ref;

  final List<MockPost> _store = List.of(MockData.posts());

  Future<List<MockPost>> list() async {
    await MockDelay.network();
    MockDelay.maybeThrow(message: 'Mock: Failed to load postcards.');
    return List.of(_store);
  }

  Future<MockPost?> findById(String id) async {
    await MockDelay.instant();
    final i = _store.indexWhere((p) => p.id == id);
    if (i < 0) return null;
    return _store[i];
  }

  Future<List<MockComment>> comments(String postId) async {
    await MockDelay.network();
    return MockData.commentsFor(postId);
  }

  Future<MockPost> publish(
    String content, {
    String? imageUrl,
    List<String>? imageUrls,
  }) async {
    await MockDelay.network();
    final session = _ref.read(mockSessionProvider);
    final urls = imageUrls != null && imageUrls.isNotEmpty
        ? imageUrls
        : (imageUrl != null && imageUrl.isNotEmpty ? <String>[imageUrl] : null);
    final first = urls != null && urls.isNotEmpty ? urls.first : null;
    final created = MockPost(
      id: 'p_${DateTime.now().millisecondsSinceEpoch}',
      author: session.user,
      content: content,
      createdAt: DateTime.now(),
      commentCount: 0,
      imageUrl: first,
      imageUrls: urls,
      reviewStatus: 1,
    );
    _store.insert(0, created);
    _ref.read(mockSessionProvider.notifier).grant(1);
    return created;
  }

  Future<void> reportPost(String postId, String reason) async {
    await MockDelay.network();
  }

  Future<void> reportComment(String commentId, String reason) async {
    await MockDelay.network();
  }
}

/// Directory repository（通信名录）。
class MockDirectoryRepository {
  MockDirectoryRepository();

  final List<MockUser> _users = List.of(MockData.users);

  Future<List<MockUser>> list({
    String? countryCode,
    int? minAge,
    int? maxAge,
    Set<String> interests = const {},
    String sort = 'DEFAULT',
    int? viewerBirthYear,
    Set<String> viewerInterests = const {},
  }) async {
    await MockDelay.network();
    MockDelay.maybeThrow(message: 'Mock: Failed to load directory.');
    var result = List<MockUser>.from(_users);
    if (countryCode != null && countryCode.isNotEmpty) {
      result = result.where((u) => u.countryCode == countryCode).toList();
    }
    if (minAge != null) {
      result = result.where((u) => u.age >= minAge).toList();
    }
    if (maxAge != null) {
      result = result.where((u) => u.age <= maxAge).toList();
    }
    if (interests.isNotEmpty) {
      result = result.where((u) {
        return u.interests.any(interests.contains);
      }).toList();
    }
    switch (sort.toUpperCase()) {
      case 'SAME_AGE':
        final vy = viewerBirthYear;
        if (vy != null) {
          result.sort((a, b) {
            final da = (a.birthYear - vy).abs();
            final db = (b.birthYear - vy).abs();
            return da.compareTo(db);
          });
        }
        break;
      case 'SHARED_INTEREST':
        int shared(MockUser u) =>
            u.interests.where(viewerInterests.contains).length;
        result.sort((a, b) => shared(b).compareTo(shared(a)));
        break;
      default:
        break;
    }
    return result;
  }

  Future<MockUser?> findById(String id) async {
    await MockDelay.instant();
    for (final u in _users) {
      if (u.id == id) return u;
    }
    return null;
  }
}

/// Mailbox repository（信箱）。
class MockMailboxRepository {
  MockMailboxRepository(this._ref);

  final Ref _ref;
  final List<MockLetter> _letters = List.of(MockData.letters());
  final Set<String> _activeFriendPairs = {};

  String _pairKey(String userIdA, String userIdB) {
    return userIdA.compareTo(userIdB) < 0
        ? '$userIdA:$userIdB'
        : '$userIdB:$userIdA';
  }

  bool _friends(String a, String b) {
    return _activeFriendPairs.contains(_pairKey(a, b));
  }

  /// 是否与对端已建联（邮政 **Connections 好友列表** 展示前提之一）。
  bool friendsWithPeer(String peerId) {
    final me = _ref.read(mockSessionProvider).user.id;
    return _friends(me, peerId);
  }

  void _advanceRegistered() {
    final now = DateTime.now();
    for (final l in _letters) {
      if (l.status != LetterStatus.registered) continue;
      final eta = l.deliveryAt;
      if (eta != null && !now.isBefore(eta)) {
        l.status = LetterStatus.delivered;
      }
    }
  }

  Future<List<MockLetter>> list() async {
    await MockDelay.network();
    _advanceRegistered();
    return List.of(_letters);
  }

  /// 邮政待办：与对端尚未建联的信件（含运输中 / 已挂号 / 已送达待 accept）。
  Future<List<MockLetter>> listPostalInbox() async {
    await MockDelay.network();
    _advanceRegistered();
    final me = _ref.read(mockSessionProvider).user.id;
    return _letters.where((l) => !_friends(me, l.peer.id)).toList();
  }

  /// 全量归档（含已建联后的历史信件）。
  Future<List<MockLetter>> listArchive() async {
    await MockDelay.network();
    _advanceRegistered();
    final sorted = List<MockLetter>.of(_letters)
      ..sort((a, b) => b.sentAt.compareTo(a.sentAt));
    return sorted;
  }

  Future<MockLetter?> findById(String id) async {
    await MockDelay.instant();
    _advanceRegistered();
    for (final l in _letters) {
      if (l.id == id) return l;
    }
    return null;
  }

  /// 发送信件：平邮运输中；挂号非 VIP 先 `registered` 再自动送达；VIP 挂号直发 `delivered`。
  Future<MockLetter> send({
    required MockUser peer,
    required String body,
    required LetterType type,
  }) async {
    await MockDelay.network();
    final session = _ref.read(mockSessionProvider);

    if (type == LetterType.registered && !session.isVip) {
      _ref.read(mockSessionProvider.notifier).consume(1);
    }

    final now = DateTime.now();
    late final LetterSendMode sendMode;
    late final LetterStatus initialStatus;
    late final DateTime delivery;
    if (type == LetterType.standard) {
      sendMode = LetterSendMode.standardPost;
      initialStatus = LetterStatus.delivering;
      delivery = now.add(Duration(seconds: 30 + math.Random().nextInt(150)));
    } else if (session.isVip) {
      sendMode = LetterSendMode.directVip;
      initialStatus = LetterStatus.delivered;
      delivery = now;
    } else {
      sendMode = LetterSendMode.registeredMail;
      initialStatus = LetterStatus.registered;
      delivery = now.add(const Duration(seconds: 2));
    }
    final letter = MockLetter(
      id: 'l_${now.millisecondsSinceEpoch}',
      peer: peer,
      preview: body.split('\n').first,
      body: body,
      type: type,
      status: initialStatus,
      sentAt: now,
      deliveryAt: delivery,
      outgoing: true,
      sendMode: sendMode,
    );
    _letters.insert(0, letter);
    return letter;
  }

  /// 加速：消耗 1 邮票（VIP 不消耗），平邮立即送达。
  Future<MockLetter> speedUp(String letterId) async {
    await MockDelay.network();
    final session = _ref.read(mockSessionProvider);
    if (!session.isVip) {
      _ref.read(mockSessionProvider.notifier).consume(1);
    }
    final i = _letters.indexWhere((l) => l.id == letterId);
    if (i < 0) {
      throw ApiBusinessException(404, 'Mock: Letter not found.');
    }
    final l = _letters[i];
    l.status = LetterStatus.delivered;
    l.deliveryAt = DateTime.now();
    return l;
  }

  /// 收件方建立建联（Mock：写入好友对，供 **Connections 好友列表** 与真机 `/mailbox/friends` 语义一致）。
  Future<void> acceptPostalConnection(String letterId) async {
    await MockDelay.network();
    final me = _ref.read(mockSessionProvider).user.id;
    final l = await findById(letterId);
    if (l == null) {
      throw ApiBusinessException(404, 'Mock: Letter not found.');
    }
    if (l.outgoing) {
      throw ApiBusinessException(400, 'Mock: Only the recipient can accept.');
    }
    if (l.status != LetterStatus.delivered) {
      throw ApiBusinessException(
        400,
        'Mock: Letter must be delivered before connecting.',
      );
    }
    _activeFriendPairs.add(_pairKey(me, l.peer.id));
  }

  Future<MockLetter> reply(String letterId, String body) async {
    await MockDelay.network();
    final original = await findById(letterId);
    if (original == null) {
      throw ApiBusinessException(404, 'Mock: Letter not found.');
    }
    return send(peer: original.peer, body: body, type: LetterType.standard);
  }

  /// 好友列表行 Mock（每 peer 取最近一封信作预览；**非** TIM 会话列表 API）。
  Future<List<MockImConnectionRow>> listMockConnections() async {
    await MockDelay.network();
    _advanceRegistered();
    final me = _ref.read(mockSessionProvider).user.id;
    final best = <String, MockLetter>{};
    for (final l in _letters) {
      if (!_friends(me, l.peer.id)) continue;
      final prev = best[l.peer.id];
      if (prev == null || l.sentAt.isAfter(prev.sentAt)) {
        best[l.peer.id] = l;
      }
    }
    final rows =
        best.values
            .map(
              (l) => MockImConnectionRow(
                peer: l.peer,
                lastMessage: l.preview,
                lastTime: l.sentAt,
              ),
            )
            .toList()
          ..sort((a, b) => b.lastTime.compareTo(a.lastTime));
    return rows;
  }
}

/// Stamps ledger repository。
class MockStampsRepository {
  Future<List<MockStampLedgerEntry>> list() async {
    await MockDelay.network();
    return MockData.stampLedger();
  }
}

final mockPostsRepositoryProvider = Provider<MockPostsRepository>(
  MockPostsRepository.new,
);

final mockDirectoryRepositoryProvider = Provider<MockDirectoryRepository>(
  (_) => MockDirectoryRepository(),
);

final mockMailboxRepositoryProvider = Provider<MockMailboxRepository>(
  MockMailboxRepository.new,
);

final mockStampsRepositoryProvider = Provider<MockStampsRepository>(
  (_) => MockStampsRepository(),
);
