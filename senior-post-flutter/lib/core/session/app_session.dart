import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../bootstrap/app_bootstrap.dart';
import '../i18n/app_locale_provider.dart';
import '../models/domain_models.dart';

/// 登录后会话：当前用户展示态（来自 `/api/auth/me`）。
class AppSessionState {
  AppSessionState({required this.user});

  final AppUser user;

  bool get isVip => user.isVip;

  AppSessionState copyWith({AppUser? user}) {
    return AppSessionState(user: user ?? this.user);
  }
}

class AppSessionNotifier extends StateNotifier<AppSessionState> {
  AppSessionNotifier(this._ref) : super(AppSessionState(user: _guestUser));

  final Ref _ref;

  static const AppUser _guestUser = AppUser(
    id: '',
    nickname: '',
    email: '',
    countryCode: '',
    countryName: '',
    birthYear: 1970,
    bio: '',
    interests: [],
  );

  void clear() {
    state = AppSessionState(user: _guestUser);
  }

  /// 首封信发送成功后的本地兜底（与后端 markFirstLetterDone 对齐）。
  void markFirstLetterDoneLocally() {
    if (state.user.firstLetterDone == true) return;
    state = state.copyWith(
      user: state.user.copyWith(firstLetterDone: true),
    );
  }

  void updateProfile({
    String? nickname,
    String? bio,
    String? countryCode,
    String? countryName,
    List<String>? interests,
    List<int>? interestTagIds,
    String? avatarUrl,
    int? avatarAuditStatus,
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
        avatarAuditStatus: avatarAuditStatus,
      ),
    );
  }

  /// 同步后端 `AppPublicUserVO`（登录/注册 `user`、`/api/auth/me`、PATCH profile）。
  void applyFromPublicUserVo(Map<String, dynamic> m) {
    final code = (m['countryCode'] as String?) ?? '';
    final lang = _ref.read(appLocaleProvider)?.languageCode ?? 'en';
    final boot = _ref.read(appBootstrapProvider(lang));
    final countries = boot.valueOrNull?.countries ?? const <CountryItem>[];
    var nameEn = code;
    for (final c in countries) {
      if (c.code == code) {
        nameEn = c.displayName(lang);
        break;
      }
    }
    final uid = m['id'];
    final idStr = uid == null
        ? state.user.id
        : (uid is int ? '$uid' : (uid as num).toString());
    DateTime? delReq;
    final dr = m['deletionRequestedAt'];
    if (dr is String) {
      delReq = DateTime.tryParse(dr);
    } else if (dr is List && dr.length >= 3) {
      delReq = DateTime(
        (dr[0] as num).toInt(),
        (dr[1] as num).toInt(),
        (dr[2] as num).toInt(),
        dr.length > 3 ? (dr[3] as num).toInt() : 0,
        dr.length > 4 ? (dr[4] as num).toInt() : 0,
        dr.length > 5 ? (dr[5] as num).toInt() : 0,
      );
    }
    DateTime? delEff;
    final de = m['deletionEffectiveAt'];
    if (de is String) {
      delEff = DateTime.tryParse(de);
    } else if (de is List && de.length >= 3) {
      delEff = DateTime(
        (de[0] as num).toInt(),
        (de[1] as num).toInt(),
        (de[2] as num).toInt(),
        de.length > 3 ? (de[3] as num).toInt() : 0,
        de.length > 4 ? (de[4] as num).toInt() : 0,
        de.length > 5 ? (de[5] as num).toInt() : 0,
      );
    }
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
    var bindProvider = state.user.bindProvider;
    if (m.containsKey('bindProvider')) {
      bindProvider = m['bindProvider'] as String?;
    } else if (idStr != state.user.id) {
      bindProvider = null;
    }
    state = state.copyWith(
      user: AppUser(
        id: idStr,
        nickname: (m['nickname'] as String?) ?? state.user.nickname,
        email: m.containsKey('email')
            ? ((m['email'] as String?) ?? '')
            : state.user.email,
        countryCode: code,
        countryName: nameEn,
        birthYear: (m['birthYear'] as num?)?.toInt() ?? state.user.birthYear,
        bio: m['bio'] as String? ?? '',
        interests: interests,
        interestTagIds: interestTagIds,
        avatarUrl: m['avatarUrl'] as String?,
        avatarAuditStatus: (m['avatarAuditStatus'] as num?)?.toInt(),
        isVip: m['isVip'] as bool? ?? state.user.isVip,
        deletionRequestedAt: delReq,
        deletionEffectiveAt: delEff,
        emailVerified: m['emailVerified'] as bool? ?? state.user.emailVerified,
        language: m['language'] as String? ?? state.user.language,
        city: m['city'] as String? ?? state.user.city,
        latitude: (m['latitude'] as num?)?.toDouble() ?? state.user.latitude,
        longitude: (m['longitude'] as num?)?.toDouble() ?? state.user.longitude,
        writingStyle: m['writingStyle'] as String? ?? state.user.writingStyle,
        // 换账号登录时勿沿用上一会话的首封信标记。
        firstLetterDone: m.containsKey('firstLetterDone')
            ? m['firstLetterDone'] as bool?
            : (idStr != state.user.id
                ? null
                : state.user.firstLetterDone),
        bound: m.containsKey('bound')
            ? m['bound'] as bool? ?? false
            : ((m['email'] as String?)?.trim().isNotEmpty == true
                ? true
                : (idStr != state.user.id ? false : state.user.bound)),
        bindProvider: bindProvider,
        signupChannel: m.containsKey('signupChannel')
            ? m['signupChannel'] as String?
            : (idStr != state.user.id ? null : state.user.signupChannel),
        canBind: m.containsKey('canBind')
            ? m['canBind'] as bool? ?? false
            : (idStr != state.user.id ? false : state.user.canBind),
      ),
    );
  }
}

final appSessionProvider =
    StateNotifierProvider<AppSessionNotifier, AppSessionState>((ref) {
      return AppSessionNotifier(ref);
    });
