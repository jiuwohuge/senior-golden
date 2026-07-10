package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.pros.post.biz.mapper.PasswordResetTokenMapper;
import cn.nine.pros.post.biz.model.domain.PasswordResetTokenDomain;
import cn.nine.pros.post.biz.service.base.PasswordResetTokenService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class PasswordResetTokenServiceImpl extends ServiceImpl<PasswordResetTokenMapper, PasswordResetTokenDomain>
        implements PasswordResetTokenService {

    @Override
    public long countCreatedSince(long userId, String purpose, LocalDateTime since) {
        LambdaQueryWrapper<PasswordResetTokenDomain> q = new LambdaQueryWrapper<PasswordResetTokenDomain>()
                .eq(PasswordResetTokenDomain::getUserId, userId)
                .ge(PasswordResetTokenDomain::getCreatedAt, since);
        if (StringUtils.hasText(purpose)) {
            q.eq(PasswordResetTokenDomain::getPurpose, purpose);
        }
        return count(q);
    }

    @Override
    public PasswordResetTokenDomain findLatestByUserId(long userId) {
        return getOne(new LambdaQueryWrapper<PasswordResetTokenDomain>()
                .eq(PasswordResetTokenDomain::getUserId, userId)
                .orderByDesc(PasswordResetTokenDomain::getId)
                .last("LIMIT 1"));
    }

    @Override
    public List<PasswordResetTokenDomain> listValidPasswordResetCandidates(long userId, LocalDateTime now, int limit) {
        return list(new LambdaQueryWrapper<PasswordResetTokenDomain>()
                .eq(PasswordResetTokenDomain::getUserId, userId)
                .and(w -> w.eq(PasswordResetTokenDomain::getPurpose, "password_reset")
                        .or()
                        .isNull(PasswordResetTokenDomain::getPurpose))
                .isNull(PasswordResetTokenDomain::getUsedAt)
                .gt(PasswordResetTokenDomain::getExpiresAt, now)
                .orderByDesc(PasswordResetTokenDomain::getId)
                .last("LIMIT " + Math.max(1, limit)));
    }

    @Override
    public PasswordResetTokenDomain findValidByUserPurposeAndHash(
            long userId, String purpose, String codeHash, LocalDateTime now) {
        return getOne(new LambdaQueryWrapper<PasswordResetTokenDomain>()
                .eq(PasswordResetTokenDomain::getUserId, userId)
                .eq(PasswordResetTokenDomain::getPurpose, purpose)
                .eq(PasswordResetTokenDomain::getCodeHash, codeHash)
                .isNull(PasswordResetTokenDomain::getUsedAt)
                .gt(PasswordResetTokenDomain::getExpiresAt, now)
                .orderByDesc(PasswordResetTokenDomain::getId)
                .last("LIMIT 1"));
    }
}
