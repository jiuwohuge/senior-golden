package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.pros.post.biz.mapper.UserIdentityMapper;
import cn.nine.pros.post.biz.model.domain.UserIdentityDomain;
import cn.nine.pros.post.biz.service.base.UserIdentityService;
import cn.nine.pros.post.biz.service.base.support.DeletedUniqueKeySupport;
import cn.nine.pros.post.client.common.constant.AuthProvider;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class UserIdentityServiceImpl extends ServiceImpl<UserIdentityMapper, UserIdentityDomain>
        implements UserIdentityService {

    private static final String ARCHIVED_MARKER = DeletedUniqueKeySupport.MARKER;

    @Override
    public UserIdentityDomain findActiveByProviderUid(String provider, String providerUid) {
        if (!StringUtils.hasText(provider) || !StringUtils.hasText(providerUid)) {
            return null;
        }
        String uid = normalizeUid(provider, providerUid);
        if (uid.contains(ARCHIVED_MARKER)) {
            return null;
        }
        return getOne(new LambdaQueryWrapper<UserIdentityDomain>()
                .eq(UserIdentityDomain::getProvider, provider.trim().toLowerCase())
                .eq(UserIdentityDomain::getProviderUid, uid)
                .eq(UserIdentityDomain::isDelFlag, false));
    }

    @Override
    public UserIdentityDomain findActiveEmailByUid(String normalizedEmail) {
        return findActiveByProviderUid(AuthProvider.EMAIL, normalizedEmail);
    }

    @Override
    public List<UserIdentityDomain> listActiveByUserId(long userId) {
        return list(new LambdaQueryWrapper<UserIdentityDomain>()
                .eq(UserIdentityDomain::getUserId, userId)
                .eq(UserIdentityDomain::isDelFlag, false));
    }

    @Override
    public UserIdentityDomain findActiveEmailIdentity(long userId) {
        return getOne(new LambdaQueryWrapper<UserIdentityDomain>()
                .eq(UserIdentityDomain::getUserId, userId)
                .eq(UserIdentityDomain::getProvider, AuthProvider.EMAIL)
                .eq(UserIdentityDomain::isDelFlag, false)
                .notLike(UserIdentityDomain::getProviderUid, ARCHIVED_MARKER)
                .last("LIMIT 1"));
    }

    @Override
    public void createEmailIdentity(long userId, String email, String passwordHash, long auditUserId) {
        UserIdentityDomain row = new UserIdentityDomain();
        row.initAudit(auditUserId);
        row.setUserId(userId);
        row.setProvider(AuthProvider.EMAIL);
        row.setProviderUid(email.trim().toLowerCase());
        row.setPasswordHash(passwordHash);
        save(row);
    }

    @Override
    public void createOAuthIdentity(long userId, String provider, String providerUid, long auditUserId) {
        UserIdentityDomain row = new UserIdentityDomain();
        row.initAudit(auditUserId);
        row.setUserId(userId);
        row.setProvider(provider.trim().toLowerCase());
        row.setProviderUid(providerUid.trim());
        row.setPasswordHash(null);
        save(row);
    }

    @Override
    public void releaseAllForUser(long userId, LocalDateTime at) {
        List<UserIdentityDomain> rows = listActiveByUserId(userId);
        for (UserIdentityDomain row : rows) {
            String archived = archiveUid(row.getProvider(), row.getProviderUid(), at);
            // 归档 UID 释放唯一约束后，同时打 del_flag，避免仍被 listActive 命中。
            LambdaUpdateWrapper<UserIdentityDomain> uw = new LambdaUpdateWrapper<UserIdentityDomain>()
                    .eq(UserIdentityDomain::getId, row.getId())
                    .set(UserIdentityDomain::getProviderUid, archived)
                    .set(UserIdentityDomain::isDelFlag, true)
                    .set(UserIdentityDomain::getUpdatedAt, at)
                    .set(UserIdentityDomain::getUpdatedBy, userId);
            update(uw);
        }
    }

    @Override
    public boolean hasOAuthOnly(long userId) {
        List<UserIdentityDomain> rows = listActiveByUserId(userId);
        boolean hasEmail = false;
        for (UserIdentityDomain row : rows) {
            if (AuthProvider.EMAIL.equals(row.getProvider())
                    && StringUtils.hasText(row.getPasswordHash())
                    && !row.getProviderUid().contains(ARCHIVED_MARKER)) {
                hasEmail = true;
                break;
            }
        }
        return !hasEmail && rows.stream().anyMatch(r -> AuthProvider.GOOGLE.equals(r.getProvider())
                || AuthProvider.APPLE.equals(r.getProvider()));
    }

    @Override
    public void updatePasswordHash(long identityId, String passwordHash, long auditUserId, LocalDateTime at) {
        update(new LambdaUpdateWrapper<UserIdentityDomain>()
                .eq(UserIdentityDomain::getId, identityId)
                .set(UserIdentityDomain::getPasswordHash, passwordHash)
                .set(UserIdentityDomain::getUpdatedAt, at)
                .set(UserIdentityDomain::getUpdatedBy, auditUserId));
    }

    private static String normalizeUid(String provider, String providerUid) {
        if (AuthProvider.EMAIL.equalsIgnoreCase(provider)) {
            return providerUid.trim().toLowerCase();
        }
        return providerUid.trim();
    }

    private static String archiveUid(String provider, String uid, LocalDateTime at) {
        if (!StringUtils.hasText(uid)) {
            return uid;
        }
        if (AuthProvider.EMAIL.equalsIgnoreCase(provider)) {
            return DeletedUniqueKeySupport.archiveEmail(uid, at);
        }
        return DeletedUniqueKeySupport.archiveProviderUid(uid, at);
    }
}
