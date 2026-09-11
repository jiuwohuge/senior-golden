import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_exception.dart';
import '../../core/network/dio_provider.dart';

/// Play / Plus 商品 ID（与后端 `PlusEntitlementSupport` 一致）。
abstract final class PlusProductIds {
  static const String monthly = 'plus_monthly';
  static const String yearly = 'plus_yearly';
  static const Set<String> all = {monthly, yearly};
}

/// SKU 展示项（对齐 `PlusSkuItemVO`）。
class PlusSkuItem {
  const PlusSkuItem({required this.productId, this.preferred = false});

  final String productId;
  final bool preferred;
}

/// 订阅状态快照（对齐 `SubscriptionStatusVO`）。
class SubscriptionStatus {
  const SubscriptionStatus({
    required this.state,
    this.productId,
    this.expiryAt,
    this.isTrial = false,
    this.source,
    this.entitled = false,
    this.aiQuotaLimit = 0,
    this.aiQuotaUsed = 0,
    this.aiQuotaRemaining = 0,
    this.recallWindowMinutes = 0,
    this.skus = const [],
  });

  /// none | trial | active | expired
  final String state;
  final String? productId;
  final DateTime? expiryAt;
  final bool isTrial;
  final String? source;
  final bool entitled;
  final int aiQuotaLimit;
  final int aiQuotaUsed;
  final int aiQuotaRemaining;
  final int recallWindowMinutes;
  final List<PlusSkuItem> skus;

  bool get isNone => state == 'none';
  bool get isTrialState => state == 'trial';
  bool get isActive => state == 'active';
  bool get isExpired => state == 'expired';
}

/// 单次购买校验入参（对齐 `PlayPurchaseVerifyInDto`）。
class PlayPurchaseVerifyBody {
  const PlayPurchaseVerifyBody({
    required this.purchaseToken,
    required this.productId,
    this.orderId,
    this.packageName,
    this.acknowledged,
    this.isTrial,
  });

  final String purchaseToken;
  final String productId;
  final String? orderId;
  final String? packageName;
  final bool? acknowledged;
  final bool? isTrial;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'purchaseToken': purchaseToken,
    'productId': productId,
    if (orderId != null && orderId!.isNotEmpty) 'orderId': orderId,
    if (packageName != null && packageName!.isNotEmpty)
      'packageName': packageName,
    if (acknowledged != null) 'acknowledged': acknowledged,
    if (isTrial != null) 'isTrial': isTrial,
  };
}

/// 与 `/api/billing/*` 对齐：订阅状态、校验购买、恢复、mock-sync、测试覆盖。
class BillingRemoteRepository {
  BillingRemoteRepository(this._dio);

  final Dio _dio;

  /// GET `/api/billing/subscription`
  Future<SubscriptionStatus> fetchSubscription() async {
    try {
      final r = await _dio.get<dynamic>('/api/billing/subscription');
      return _mapStatus(_unwrapMap(r));
    } catch (e, st) {
      debugPrint('billing fetchSubscription failed: $e\n$st');
      rethrow;
    }
  }

  /// POST `/api/billing/verify-purchase`
  Future<SubscriptionStatus> verifyPurchase(PlayPurchaseVerifyBody body) async {
    try {
      final r = await _dio.post<dynamic>(
        '/api/billing/verify-purchase',
        data: body.toJson(),
      );
      return _mapStatus(_unwrapMap(r));
    } catch (e, st) {
      debugPrint('billing verifyPurchase failed: $e\n$st');
      rethrow;
    }
  }

  /// POST `/api/billing/restore` — [purchases] 可空，仅重读服务端权益。
  Future<SubscriptionStatus> restore({
    List<PlayPurchaseVerifyBody>? purchases,
  }) async {
    try {
      final data = <String, dynamic>{
        if (purchases != null)
          'purchases': purchases.map((e) => e.toJson()).toList(),
      };
      final r = await _dio.post<dynamic>('/api/billing/restore', data: data);
      return _mapStatus(_unwrapMap(r));
    } catch (e, st) {
      debugPrint('billing restore failed: $e\n$st');
      rethrow;
    }
  }

  /// POST `/api/billing/test-override` — 仅服务端开启测试开关时可用。
  Future<SubscriptionStatus> testOverride({
    required String state,
    String? productId,
  }) async {
    try {
      final r = await _dio.post<dynamic>(
        '/api/billing/test-override',
        data: <String, dynamic>{
          'state': state,
          if (productId != null && productId.isNotEmpty) 'productId': productId,
        },
      );
      return _mapStatus(_unwrapMap(r));
    } catch (e, st) {
      debugPrint('billing testOverride failed: $e\n$st');
      rethrow;
    }
  }

  /// POST `/api/billing/mock-sync` — 走服务端 `syncPurchase`（MockBillingProvider）。
  ///
  /// [scenario]：`PURCHASED` / `PENDING` / `RENEW` / `CANCEL` / `EXPIRE` /
  /// `REFUND` / `REVOKE`。需 `billing.mock-enabled` 且非 prod。
  Future<SubscriptionStatus> mockSync({
    required String scenario,
    String? productId,
    String? purchaseToken,
  }) async {
    try {
      final r = await _dio.post<dynamic>(
        '/api/billing/mock-sync',
        data: <String, dynamic>{
          'scenario': scenario,
          if (productId != null && productId.isNotEmpty) 'productId': productId,
          if (purchaseToken != null && purchaseToken.isNotEmpty)
            'purchaseToken': purchaseToken,
        },
      );
      return _mapStatus(_unwrapMap(r));
    } catch (e, st) {
      debugPrint('billing mockSync failed: $e\n$st');
      rethrow;
    }
  }
}

SubscriptionStatus _mapStatus(Map<String, dynamic> m) {
  final skusRaw = m['skus'];
  final skus = <PlusSkuItem>[];
  if (skusRaw is List<dynamic>) {
    for (final row in skusRaw) {
      if (row is! Map<String, dynamic>) continue;
      final id = (row['productId'] as String?)?.trim() ?? '';
      if (id.isEmpty) continue;
      skus.add(
        PlusSkuItem(
          productId: id,
          preferred: row['preferred'] as bool? ?? false,
        ),
      );
    }
  }
  return SubscriptionStatus(
    state: (m['state'] as String?)?.trim() ?? 'none',
    productId: (m['productId'] as String?)?.trim(),
    expiryAt: _parseDate(m['expiryAt']),
    isTrial: m['isTrial'] as bool? ?? false,
    source: (m['source'] as String?)?.trim(),
    entitled: m['entitled'] as bool? ?? false,
    aiQuotaLimit: (m['aiQuotaLimit'] as num?)?.toInt() ?? 0,
    aiQuotaUsed: (m['aiQuotaUsed'] as num?)?.toInt() ?? 0,
    aiQuotaRemaining: (m['aiQuotaRemaining'] as num?)?.toInt() ?? 0,
    recallWindowMinutes: (m['recallWindowMinutes'] as num?)?.toInt() ?? 0,
    skus: skus,
  );
}

DateTime? _parseDate(Object? v) {
  if (v == null) return null;
  if (v is String && v.isNotEmpty) {
    // 服务端多为 ISO；偶发空格分隔时替换为 T 再解析。
    return DateTime.tryParse(v.replaceAll(' ', 'T')) ?? DateTime.tryParse(v);
  }
  return null;
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

final billingRemoteProvider = Provider<BillingRemoteRepository>(
  (ref) => BillingRemoteRepository(ref.read(dioProvider)),
);

/// 当前用户 Plus 订阅与 AI 额度快照。
final subscriptionStatusProvider = FutureProvider<SubscriptionStatus>((
  ref,
) async {
  return ref.read(billingRemoteProvider).fetchSubscription();
});
