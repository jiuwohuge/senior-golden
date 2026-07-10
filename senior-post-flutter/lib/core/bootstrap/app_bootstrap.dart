import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/interest_tag_option.dart';
import '../network/dio_provider.dart';

/// 与后端 `AppBootstrapVO` / `AppCountryVO` / `AppVipProductConfigVO` 对齐。
class AppVipProductConfig {
  const AppVipProductConfig({
    required this.productEnabled,
    required this.displayName,
    required this.tagline,
    required this.taglineZh,
    required this.unlimitedStampsBenefit,
    required this.standardDeliveryHours,
  });

  final bool productEnabled;
  final String displayName;
  final String tagline;
  final String taglineZh;
  final bool unlimitedStampsBenefit;
  final int standardDeliveryHours;

  factory AppVipProductConfig.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) {
      return AppVipProductConfig.defaults;
    }
    return AppVipProductConfig(
      productEnabled: json['productEnabled'] as bool? ?? true,
      displayName: (json['displayName'] as String?)?.trim().isNotEmpty == true
          ? (json['displayName'] as String).trim()
          : 'VIP',
      tagline: (json['tagline'] as String?)?.trim().isNotEmpty == true
          ? (json['tagline'] as String).trim()
          : 'Unlimited stamps · Priority delivery · Ad-free',
      taglineZh: (json['taglineZh'] as String?)?.trim().isNotEmpty == true
          ? (json['taglineZh'] as String).trim()
          : '无限邮票 · 优先送达 · 无广告干扰',
      unlimitedStampsBenefit: json['unlimitedStampsBenefit'] as bool? ?? true,
      standardDeliveryHours: (json['standardDeliveryHours'] as num?)?.toInt() ?? 0,
    );
  }

  static const AppVipProductConfig defaults = AppVipProductConfig(
    productEnabled: true,
    displayName: 'VIP',
    tagline: 'Unlimited stamps · Priority delivery · Ad-free',
    taglineZh: '无限邮票 · 优先送达 · 无广告干扰',
    unlimitedStampsBenefit: true,
    standardDeliveryHours: 0,
  );

  String taglineForLanguage(String languageCode) {
    if (languageCode.toLowerCase().startsWith('zh') && taglineZh.isNotEmpty) {
      return taglineZh;
    }
    return tagline;
  }
}

class AppBootstrapData {
  const AppBootstrapData({
    required this.minRegisterAge,
    required this.countries,
    this.interestTagOptions = const [],
    this.vipProduct = AppVipProductConfig.defaults,
    this.dailyLetterQuota = 5,
  });

  final int minRegisterAge;
  final List<CountryItem> countries;
  final List<InterestTagOption> interestTagOptions;
  final AppVipProductConfig vipProduct;
  final int dailyLetterQuota;

  factory AppBootstrapData.fromJson(Map<String, dynamic> json) {
    final countriesRaw = json['countries'] as List<dynamic>? ?? const [];
    final tagsRaw = json['interestTagOptions'] as List<dynamic>? ?? const [];
    final vipRaw = json['vipProduct'];
    return AppBootstrapData(
      minRegisterAge: (json['minRegisterAge'] as num?)?.toInt() ?? 45,
      dailyLetterQuota: (json['dailyLetterQuota'] as num?)?.toInt() ?? 5,
      countries: countriesRaw
          .whereType<Map<String, dynamic>>()
          .map(CountryItem.fromJson)
          .toList(),
      interestTagOptions: tagsRaw
          .whereType<Map<String, dynamic>>()
          .map(InterestTagOption.fromJson)
          .where((e) => e.id > 0 && e.tagName.isNotEmpty)
          .toList(),
      vipProduct: vipRaw is Map<String, dynamic>
          ? AppVipProductConfig.fromJson(vipRaw)
          : AppVipProductConfig.defaults,
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

/// 启动配置（注册门槛、国家列表、兴趣标签选项）。未登录即可调用，与 `/api/bootstrap/init?lang=` 同步。
final appBootstrapProvider = FutureProvider.family<AppBootstrapData, String>((ref, lang) async {
  final dio = ref.read(dioProvider);
  final res = await dio.get<Map<String, dynamic>>(
    '/api/bootstrap/init',
    queryParameters: <String, dynamic>{if (lang.isNotEmpty) 'lang': lang},
  );
  final raw = unwrapData<Map<String, dynamic>>(res, (r) {
    return r! as Map<String, dynamic>;
  });
  return AppBootstrapData.fromJson(raw);
});

/// Debug 下附加在「加载失败」文案后，便于区分真机 BaseURL、明文 HTTP、连接拒绝等。
String bootstrapDebugErrorHint(Object error) {
  if (!kDebugMode) {
    return '';
  }
  if (error is DioException) {
    final buf = StringBuffer()
      ..writeln()
      ..writeln('[Dio ${error.type.name}] ${error.message ?? error}');
    if (error.response?.statusCode != null) {
      buf.writeln('HTTP ${error.response!.statusCode}');
    }
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout) {
      buf.writeln(
        '真机/模拟器请检查：同一 Wi‑Fi、后端已启动；'
        'Debug 下可在登录页长按「查看功能引导」配置 Base URL，'
        '或使用 --dart-define=API_BASE_URL=...',
      );
    }
    return buf.toString();
  }
  return '\n\n$error';
}
