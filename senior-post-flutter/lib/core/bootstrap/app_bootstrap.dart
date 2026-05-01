import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/dio_provider.dart';

/// 与后端 `AppBootstrapVO` / `AppCountryVO` 对齐。
class AppBootstrapData {
  const AppBootstrapData({
    required this.minRegisterAge,
    required this.countries,
  });

  final int minRegisterAge;
  final List<CountryItem> countries;

  factory AppBootstrapData.fromJson(Map<String, dynamic> json) {
    final countriesRaw = json['countries'] as List<dynamic>? ?? const [];
    return AppBootstrapData(
      minRegisterAge: (json['minRegisterAge'] as num?)?.toInt() ?? 45,
      countries: countriesRaw
          .whereType<Map<String, dynamic>>()
          .map(CountryItem.fromJson)
          .toList(),
    );
  }
}

class CountryItem {
  const CountryItem({
    required this.code,
    required this.nameEn,
    required this.nameZh,
  });

  factory CountryItem.fromJson(Map<String, dynamic> json) {
    return CountryItem(
      code: (json['code'] as String?) ?? '',
      nameEn: (json['nameEn'] as String?) ?? '',
      nameZh: (json['nameZh'] as String?) ?? '',
    );
  }

  final String code;
  final String nameEn;
  final String nameZh;

  /// 展示名：中文界面优先 `nameZh`，否则 `nameEn`，再退回 `code`。
  String displayName(String languageCode) {
    if (languageCode.toLowerCase().startsWith('zh') && nameZh.isNotEmpty) {
      return nameZh;
    }
    if (nameEn.isNotEmpty) {
      return nameEn;
    }
    return code;
  }
}

/// 启动配置（注册门槛、国家列表）。未登录即可调用，与 `/api/bootstrap/init` 同步。
final appBootstrapProvider = FutureProvider<AppBootstrapData>((ref) async {
  final dio = ref.read(dioProvider);
  final res = await dio.get<Map<String, dynamic>>('/api/bootstrap/init');
  final raw = unwrapData<Map<String, dynamic>>(res, (r) {
    return r! as Map<String, dynamic>;
  });
  return AppBootstrapData.fromJson(raw);
});
