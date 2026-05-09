/// 与后端 `PostAppErrorCodes` 及《底层框架能力》§4.2.1 对齐。
abstract final class BizErrorCodes {
  BizErrorCodes._();

  /// 邮票不足 → 可引导商城 / 充值。
  static const int stampInsufficient = 400301;

  /// 需要 VIP（预留）。
  static const int vipRequired = 400302;

  /// 与后端 `BusinessException(String)` 默认码一致（通用可展示错误）。
  static const int defaultBusiness = 4501;

  /// 需要自动进入统一商品聚合页的业务码。
  static const Set<int> commerceRouteCodes = {stampInsufficient, vipRequired};

  static bool shouldOpenCommerceHub(int code) =>
      commerceRouteCodes.contains(code);
}
