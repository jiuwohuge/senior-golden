import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_exception.dart';
import '../../core/models/domain_models.dart';
import '../../core/network/dio_provider.dart';

/// 与 `/api/commerce/*` 对齐：商品目录、权益与模拟购买。
class CommerceRemoteRepository {
  CommerceRemoteRepository(this._dio);

  final Dio _dio;

  /// 拉取商店商品目录（含 owned 标记）。
  Future<List<CommerceProduct>> catalog() async {
    final r = await _dio.get<dynamic>('/api/commerce/catalog');
    return _unwrapList(r).map(_mapProduct).toList();
  }

  /// 拉取当前用户已拥有的装扮/权益。
  Future<List<CommerceEntitlement>> entitlements() async {
    final r = await _dio.get<dynamic>('/api/commerce/entitlements');
    return _unwrapList(r).map(_mapEntitlement).toList();
  }

  /// MVP 模拟购买：无真实 IAP，服务端写 entitlement。
  Future<CommerceEntitlement> mockPurchase(String productId) async {
    final r = await _dio.post<dynamic>(
      '/api/commerce/mock-purchase',
      data: <String, dynamic>{'productId': int.parse(productId)},
    );
    return _mapEntitlement(_unwrapMap(r));
  }
}

CommerceProduct _mapProduct(Map<String, dynamic> m) {
  final meta = m['metadataJson'];
  return CommerceProduct(
    id: '${m['id'] ?? ''}',
    productCode: (m['productCode'] as String?) ?? '',
    productType: (m['productType'] as String?) ?? '',
    titleKey: (m['titleKey'] as String?) ?? '',
    priceCents: (m['priceCents'] as num?)?.toInt() ?? 0,
    metadata: meta is Map<String, dynamic>
        ? Map<String, dynamic>.from(meta)
        : const {},
    sortOrder: (m['sortOrder'] as num?)?.toInt() ?? 0,
    owned: m['owned'] as bool? ?? false,
  );
}

CommerceEntitlement _mapEntitlement(Map<String, dynamic> m) {
  return CommerceEntitlement(
    entitlementId: '${m['entitlementId'] ?? m['id'] ?? ''}',
    productId: '${m['productId'] ?? ''}',
    productCode: (m['productCode'] as String?) ?? '',
    productType: (m['productType'] as String?) ?? '',
    titleKey: (m['titleKey'] as String?) ?? '',
    source: m['source'] as String?,
    expiresAt: _parseDate(m['expiresAt']),
    grantedAt: _parseDate(m['grantedAt']),
  );
}

DateTime? _parseDate(Object? v) {
  if (v == null) return null;
  if (v is String && v.isNotEmpty) {
    return DateTime.tryParse(v.replaceAll(' ', 'T')) ?? DateTime.tryParse(v);
  }
  return null;
}

List<Map<String, dynamic>> _unwrapList(Response<dynamic> r) {
  final raw = r.data;
  if (raw is! Map<String, dynamic>) {
    throw ApiBusinessException(0, 'Invalid response shape');
  }
  final data = raw['data'];
  if (data is! List<dynamic>) {
    throw ApiBusinessException(0, 'Expected list data');
  }
  return data.whereType<Map<String, dynamic>>().toList();
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

final commerceRemoteProvider = Provider<CommerceRemoteRepository>(
  (ref) => CommerceRemoteRepository(ref.read(dioProvider)),
);

final commerceCatalogProvider = FutureProvider<List<CommerceProduct>>((
  ref,
) async {
  return ref.read(commerceRemoteProvider).catalog();
});

final commerceEntitlementsProvider = FutureProvider<List<CommerceEntitlement>>((
  ref,
) async {
  return ref.read(commerceRemoteProvider).entitlements();
});

/// 可用于写信的皮肤权益（含默认 skin）。
final ownedSkinEntitlementsProvider = FutureProvider<List<CommerceEntitlement>>(
  (ref) async {
    final all = await ref.watch(commerceEntitlementsProvider.future);
    return all.where((e) => e.productType == 'skin').toList();
  },
);

/// 将服务端 `titleKey` 映射为本地化标题。
String commerceProductTitle(dynamic l10n, String titleKey) {
  return switch (titleKey) {
    'commerce.product.skin.default' => l10n.commerceProductSkinDefault,
    'commerce.product.skin.vintage' => l10n.commerceProductSkinVintage,
    'commerce.product.font.default' => l10n.commerceProductFontDefault,
    'commerce.product.font.handwriting' => l10n.commerceProductFontHandwriting,
    'commerce.product.export.pdf' => l10n.commerceProductExportPdf,
    _ => titleKey.replaceAll('commerce.product.', '').replaceAll('.', ' '),
  };
}

String commerceTypeLabel(dynamic l10n, String type) {
  return switch (type) {
    'skin' => l10n.shopProductTypeSkin,
    'font' => l10n.shopProductTypeFont,
    'template' => l10n.shopProductTypeTemplate,
    'vip_bundle' => l10n.shopProductTypeVipBundle,
    'export' => l10n.shopProductTypeExport,
    'attachment' => l10n.shopProductTypeAttachment,
    _ => type,
  };
}

String formatPriceCents(int cents, dynamic l10n) {
  if (cents <= 0) return l10n.shopPriceFree;
  return l10n.shopPriceAmount((cents / 100).toStringAsFixed(2));
}
