package cn.nine.pros.post.biz.service.biz.support.oauth;

/**
 * 经服务端校验的外部 OAuth 身份（如 Google ID Token）。
 *
 * @param provider 提供方常量，例如 {@code AuthProvider.GOOGLE}
 * @param subject  提供方稳定主体（Google {@code sub}）
 * @param email    可选邮箱；非空时应为小写并 trim
 */
public record VerifiedExternalIdentity(String provider, String subject, String email) {
}
