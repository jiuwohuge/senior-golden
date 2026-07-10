package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.PasswordResetTokenDomain;
import com.baomidou.mybatisplus.extension.service.IService;

import java.time.LocalDateTime;
import java.util.List;

public interface PasswordResetTokenService extends IService<PasswordResetTokenDomain> {

    /** 用户在 since 之后创建的令牌数（可按 purpose 过滤；purpose 为空则不过滤）。 */
    long countCreatedSince(long userId, String purpose, LocalDateTime since);

    /** 用户最近一条令牌（任意 purpose）。 */
    PasswordResetTokenDomain findLatestByUserId(long userId);

    /** 未使用且未过期的 password_reset（含 purpose 为空的历史行）。 */
    List<PasswordResetTokenDomain> listValidPasswordResetCandidates(long userId, LocalDateTime now, int limit);

    /** 按 user + purpose + codeHash 取未使用未过期令牌。 */
    PasswordResetTokenDomain findValidByUserPurposeAndHash(
            long userId, String purpose, String codeHash, LocalDateTime now);
}
