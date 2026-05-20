package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.UserIdentityDomain;
import com.baomidou.mybatisplus.extension.service.IService;

import java.time.LocalDateTime;
import java.util.List;

public interface UserIdentityService extends IService<UserIdentityDomain> {

    UserIdentityDomain findActiveByProviderUid(String provider, String providerUid);

    UserIdentityDomain findActiveEmailByUid(String normalizedEmail);

    List<UserIdentityDomain> listActiveByUserId(long userId);

    UserIdentityDomain findActiveEmailIdentity(long userId);

    void createEmailIdentity(long userId, String email, String passwordHash, long auditUserId);

    void createOAuthIdentity(long userId, String provider, String providerUid, long auditUserId);

    void releaseAllForUser(long userId, LocalDateTime at);

    boolean hasOAuthOnly(long userId);
}
