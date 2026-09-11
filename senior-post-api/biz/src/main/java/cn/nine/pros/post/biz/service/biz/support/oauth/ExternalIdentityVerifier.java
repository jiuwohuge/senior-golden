package cn.nine.pros.post.biz.service.biz.support.oauth;

/**
 * 外部身份提供方 ID Token 校验抽象。
 * <p>实现须在服务端完成签名与受众校验；失败时抛出 {@code BadRequestException}。
 */
public interface ExternalIdentityVerifier {

    /**
     * 校验提供方 idToken，返回已验证身份。
     *
     * @param idToken 客户端提交的 ID Token（或本机 mock 前缀串）
     * @return 已验证的外部身份
     */
    VerifiedExternalIdentity verify(String idToken);
}
