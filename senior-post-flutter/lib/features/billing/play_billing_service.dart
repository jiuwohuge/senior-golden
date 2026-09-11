import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'billing_remote.dart';

/// Play Billing / Plus 购买服务。
///
/// **Web / Debug QA（无 Play Store）：**
/// 1. 用 Chrome / Edge 跑 `flutter run -d chrome`，登录账号。
/// 2. 打开「Plus 会员」页底部测试区（仅 `kIsWeb || kDebugMode` 可见）。
/// 3. **test-override**（Trial / Active / Expired / None）→ 直接改订阅镜像，
///    不走支付流水；需 `BILLING_TEST_OVERRIDE=true`。
/// 4. **mock-sync**（PURCHASED / PENDING / RENEW / CANCEL / EXPIRE / REFUND /
///    REVOKE）→ `POST /api/billing/mock-sync` → 服务端 `syncPurchase`；
///    需 `billing.mock-enabled` 且非 prod。测支付落库/权益机优先用 mock-sync。
/// 5. 页面会刷新订阅状态，可再测 AI 助手额度与在途撤回。
///
/// Android 真机走 Google Play Billing → verify-purchase；Web / iOS / 无商店时
/// 不崩溃，改走上述测试入口。
class PlayBillingService {
  PlayBillingService(this._billing);

  final BillingRemoteRepository _billing;
  final InAppPurchase _iap = InAppPurchase.instance;

  /// 与 `android/app/build.gradle.kts` `applicationId` 一致；verify-purchase 必传。
  static const String androidPackageName = 'cn.nine.pros.post.senior_post_flutter';

  /// Mock 生命周期场景（对齐 `MockBillingProvider` / `BillingMockSyncInDto`）。
  static const List<String> mockSyncScenarios = [
    'PURCHASED',
    'PENDING',
    'RENEW',
    'CANCEL',
    'EXPIRE',
    'REFUND',
    'REVOKE',
  ];

  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  bool _listening = false;

  /// 是否可用真实商店购买（当前仅 Android）。
  bool get supportsStorePurchase =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// 是否展示云端测试覆盖按钮（Web 或 Debug）。
  bool get showTestHarness => kIsWeb || kDebugMode;

  /// 开始监听购买流（幂等）；须在购买前调用。
  void ensurePurchaseListener({
    required void Function(SubscriptionStatus status) onVerified,
    required void Function(Object error) onError,
  }) {
    if (!supportsStorePurchase || _listening) return;
    _listening = true;
    _purchaseSub = _iap.purchaseStream.listen(
      (purchases) async {
        for (final purchase in purchases) {
          await _handlePurchase(
            purchase,
            onVerified: onVerified,
            onError: onError,
          );
        }
      },
      onError: (Object e, StackTrace st) {
        debugPrint('playBilling purchaseStream error: $e\n$st');
        onError(e);
      },
    );
  }

  Future<void> dispose() async {
    await _purchaseSub?.cancel();
    _purchaseSub = null;
    _listening = false;
  }

  /// 查询 plus_monthly / plus_yearly 详情；商店不可用时返回空列表。
  Future<List<ProductDetails>> queryPlusProducts() async {
    if (!supportsStorePurchase) return const [];
    try {
      final available = await _iap.isAvailable();
      if (!available) {
        debugPrint('playBilling store not available');
        return const [];
      }
      final response = await _iap.queryProductDetails(PlusProductIds.all);
      if (response.error != null) {
        debugPrint('playBilling queryProductDetails error: ${response.error}');
      }
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('playBilling products not found: ${response.notFoundIDs}');
      }
      return response.productDetails;
    } catch (e, st) {
      debugPrint('playBilling queryPlusProducts failed: $e\n$st');
      return const [];
    }
  }

  /// 发起购买；非 Android 请用 [applyTestOverride]。
  Future<bool> buyProduct(ProductDetails product) async {
    if (!supportsStorePurchase) {
      debugPrint('playBilling buy skipped: store not supported on this platform');
      return false;
    }
    try {
      final param = PurchaseParam(productDetails: product);
      // 订阅商品走 non-consumable 购买入口（插件约定）。
      return _iap.buyNonConsumable(purchaseParam: param);
    } catch (e, st) {
      debugPrint('playBilling buyProduct failed: $e\n$st');
      rethrow;
    }
  }

  /// 恢复购买：先触发商店 restore，再带本地购买列表调服务端（可空列表）。
  Future<SubscriptionStatus> restorePurchases() async {
    if (supportsStorePurchase) {
      try {
        await _iap.restorePurchases();
      } catch (e, st) {
        debugPrint('playBilling restorePurchases store failed: $e\n$st');
      }
    }
    try {
      return await _billing.restore();
    } catch (e, st) {
      debugPrint('playBilling restore API failed: $e\n$st');
      rethrow;
    }
  }

  /// Web / Debug：覆盖订阅状态，便于测云端门禁（无需 Play Store）。
  /// 与 [applyMockSync] 不同：不走 `syncPurchase` / 支付表。
  Future<SubscriptionStatus> applyTestOverride({
    required String state,
    String? productId,
  }) {
    return _billing.testOverride(
      state: state,
      productId: productId ?? PlusProductIds.yearly,
    );
  }

  /// Web / Debug：mock 购买生命周期，走服务端 `syncPurchase`。
  ///
  /// [scenario] 见 [mockSyncScenarios]；默认年订 [PlusProductIds.yearly]。
  /// 同 [purchaseToken] 可推进 RENEW/CANCEL 等；留空则服务端生成新 token。
  Future<SubscriptionStatus> applyMockSync({
    required String scenario,
    String? productId,
    String? purchaseToken,
  }) {
    return _billing.mockSync(
      scenario: scenario,
      productId: productId ?? PlusProductIds.yearly,
      purchaseToken: purchaseToken,
    );
  }

  Future<void> _handlePurchase(
    PurchaseDetails purchase, {
    required void Function(SubscriptionStatus status) onVerified,
    required void Function(Object error) onError,
  }) async {
    if (purchase.status == PurchaseStatus.pending) return;
    if (purchase.status == PurchaseStatus.error) {
      debugPrint('playBilling purchase error: ${purchase.error}');
      onError(purchase.error ?? StateError('purchase error'));
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
      return;
    }
    if (purchase.status == PurchaseStatus.canceled) {
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
      return;
    }
    // purchased / restored → 服务端校验落库
    final productId = purchase.productID;
    if (!PlusProductIds.all.contains(productId)) {
      debugPrint('playBilling ignore unknown product: $productId');
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
      return;
    }
    try {
      // 方案要求：productId + purchaseToken + packageName 一并交给 verify-purchase。
      final status = await _billing.verifyPurchase(
        PlayPurchaseVerifyBody(
          purchaseToken: purchase.verificationData.serverVerificationData,
          productId: productId,
          orderId: purchase.purchaseID,
          packageName: androidPackageName,
          acknowledged: false,
          // 年订首次由服务端默认试用；客户端不臆测 isTrial。
        ),
      );
      onVerified(status);
      // 仅服务端校验成功后再 complete，避免验签失败仍 acknowledge 导致无法重试
      if (purchase.pendingCompletePurchase) {
        try {
          await _iap.completePurchase(purchase);
        } catch (e, st) {
          debugPrint('playBilling completePurchase failed: $e\n$st');
        }
      }
    } catch (e, st) {
      debugPrint('playBilling verify after purchase failed: $e\n$st');
      onError(e);
    }
  }
}

final playBillingServiceProvider = Provider<PlayBillingService>((ref) {
  final service = PlayBillingService(ref.read(billingRemoteProvider));
  ref.onDispose(() {
    unawaited(service.dispose());
  });
  return service;
});
