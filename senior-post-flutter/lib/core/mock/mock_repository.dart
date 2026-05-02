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
  }) {
    state = state.copyWith(
      user: state.user.copyWith(
        nickname: nickname,
        bio: bio,
        countryCode: countryCode,
        countryName: countryName,
        interests: interests,
      ),
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

  Future<MockPost> publish(String content) async {
    await MockDelay.network();
    final session = _ref.read(mockSessionProvider);
    final created = MockPost(
      id: 'p_${DateTime.now().millisecondsSinceEpoch}',
      author: session.user,
      content: content,
      createdAt: DateTime.now(),
      commentCount: 0,
    );
    _store.insert(0, created);
    _ref.read(mockSessionProvider.notifier).grant(1);
    return created;
  }

  Future<void> reportPost(String postId, String reason) async {
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

  Future<List<MockLetter>> list() async {
    await MockDelay.network();
    return List.of(_letters);
  }

  Future<MockLetter?> findById(String id) async {
    await MockDelay.instant();
    for (final l in _letters) {
      if (l.id == id) return l;
    }
    return null;
  }

  /// 发送信件：挂号即时；平邮 30~180 秒后置为 Delivered（演示用，实际为后台延迟）。
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
    final delivery = type == LetterType.registered
        ? now
        : now.add(Duration(seconds: 30 + math.Random().nextInt(150)));
    final letter = MockLetter(
      id: 'l_${now.millisecondsSinceEpoch}',
      peer: peer,
      preview: body.split('\n').first,
      body: body,
      type: type,
      status: type == LetterType.registered
          ? LetterStatus.delivered
          : LetterStatus.delivering,
      sentAt: now,
      deliveryAt: delivery,
      outgoing: true,
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

  Future<MockLetter> reply(String letterId, String body) async {
    await MockDelay.network();
    final original = await findById(letterId);
    if (original == null) {
      throw ApiBusinessException(404, 'Mock: Letter not found.');
    }
    return send(peer: original.peer, body: body, type: LetterType.standard);
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
