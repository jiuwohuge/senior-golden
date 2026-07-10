package cn.nine.pros.post.biz.moderation;

public record ModerationRuntimeConfig(
        boolean baiduCredentialsReady,
        boolean deepseekCredentialsReady) {
}
