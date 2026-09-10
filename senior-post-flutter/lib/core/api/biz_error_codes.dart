/// 与后端 `PostAppErrorCodes` 及《底层框架能力》§4.2.1 对齐。
abstract final class BizErrorCodes {
  BizErrorCodes._();

  /// 邮票不足 → 可引导商城 / 充值。
  static const int stampInsufficient = 400301;

  /// 需要 VIP / Plus 权益。
  static const int vipRequired = 400302;

  /// AI 写信助手周额度用尽 → 引导 Plus 付费墙。
  static const int aiQuotaExhausted = 400303;

  /// 与后端 `BusinessException(String)` 默认码一致（通用可展示错误）。
  static const int defaultBusiness = 4501;

  /// 需要自动进入统一商品聚合页（邮票不足等）。
  static const Set<int> commerceRouteCodes = {stampInsufficient};

  /// Plus 付费墙：VIP 门槛或 AI 额度耗尽。
  static const Set<int> paywallRouteCodes = {vipRequired, aiQuotaExhausted};

  static bool shouldOpenCommerceHub(int code) =>
      commerceRouteCodes.contains(code);

  static bool shouldOpenPaywall(int code) => paywallRouteCodes.contains(code);
}
