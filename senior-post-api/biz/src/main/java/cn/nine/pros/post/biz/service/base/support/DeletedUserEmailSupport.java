package cn.nine.pros.post.biz.service.base.support;

import java.time.LocalDateTime;

/**
 * 账号注销/删除时释放邮箱 UNIQUE（委托 {@link DeletedUniqueKeySupport}）。
 */
public final class DeletedUserEmailSupport {

    private DeletedUserEmailSupport() {
    }

    /**
     * 将登录邮箱改写为归档形态，例如 {@code user+deleted.1716000000000@example.com}。
     */
    public static String archive(String email, LocalDateTime at) {
        return DeletedUniqueKeySupport.archiveEmail(email, at);
    }
}
