import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_exception.dart';
import '../../core/models/domain_models.dart';
import '../../core/network/dio_provider.dart';

/// 与 `GET/PATCH /api/profile/preferences` 对齐。
class PreferencesRemoteRepository {
  PreferencesRemoteRepository(this._dio);

  final Dio _dio;

  Future<UserPreferences> fetch() async {
    final r = await _dio.get<dynamic>('/api/profile/preferences');
    return _mapPreferences(_unwrapMap(r));
  }

  Future<UserPreferences> patch(UserPreferences prefs) async {
    final r = await _dio.patch<dynamic>(
      '/api/profile/preferences',
      data: <String, dynamic>{
        'privacy': <String, dynamic>{
          'hide_recommendations': prefs.hideRecommendations,
          'reject_stranger_letters': prefs.rejectStrangerMail,
        },
        'notifications': <String, dynamic>{
          'push_enabled': prefs.pushEnabled,
          'unread_badges': prefs.unreadBadges,
        },
      },
    );
    return _mapPreferences(_unwrapMap(r));
  }
}

UserPreferences _mapPreferences(Map<String, dynamic> m) {
  final privacy = m['privacy'];
  final notifications = m['notifications'];
  final privacyMap = privacy is Map<String, dynamic> ? privacy : const {};
  final notifMap = notifications is Map<String, dynamic>
      ? notifications
      : const {};
  return UserPreferences(
    hideRecommendations: _readBool(
      privacyMap['hide_recommendations'] ?? privacyMap['hideRecommendations'],
    ),
    rejectStrangerMail: _readBool(
      privacyMap['reject_stranger_letters'] ??
          privacyMap['rejectStrangerLetters'],
    ),
    pushEnabled: _readBool(
      notifMap['push_enabled'] ?? notifMap['pushEnabled'],
      defaultValue: true,
    ),
    unreadBadges: _readBool(
      notifMap['unread_badges'] ?? notifMap['unreadBadges'],
      defaultValue: true,
    ),
  );
}

bool _readBool(Object? v, {bool defaultValue = false}) {
  if (v == null) return defaultValue;
  if (v is bool) return v;
  if (v is String) return v.toLowerCase() == 'true';
  if (v is num) return v != 0;
  return defaultValue;
}

Map<String, dynamic> _unwrapMap(Response<dynamic> r) {
  final raw = r.data;
  if (raw is! Map<String, dynamic>) {
    throw ApiBusinessException(0, 'Invalid response shape');
  }
  final data = raw['data'];
  if (data is! Map<String, dynamic>) {
    throw ApiBusinessException(0, 'Expected object data');
  }
  return data;
}

final preferencesRemoteProvider = Provider<PreferencesRemoteRepository>(
  (ref) => PreferencesRemoteRepository(ref.read(dioProvider)),
);

final userPreferencesProvider = FutureProvider<UserPreferences>((ref) async {
  return ref.read(preferencesRemoteProvider).fetch();
});
