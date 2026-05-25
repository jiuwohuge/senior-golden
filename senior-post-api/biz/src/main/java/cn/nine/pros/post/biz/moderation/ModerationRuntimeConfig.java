package cn.nine.pros.post.biz.moderation;

/**
 * 机审运行时开关（来自 sys_config）与凭证就绪状态（来自环境配置，不含密钥）。
 */
public record ModerationRuntimeConfig(
        boolean postcardImageEnabled,
        boolean postcardTextEnabled,
        boolean baiduCredentialsReady,
        boolean deepseekCredentialsReady) {

    public boolean isPostcardImageActive() {
        return postcardImageEnabled && baiduCredentialsReady;
    }

    public boolean isPostcardTextActive() {
        return postcardTextEnabled && deepseekCredentialsReady;
    }
}
