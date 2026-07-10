package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.UserEntitlementDomain;
import com.baomidou.mybatisplus.extension.service.IService;

import java.util.List;

public interface UserEntitlementService extends IService<UserEntitlementDomain> {

    List<UserEntitlementDomain> listActiveForUser(Long userId);

    boolean hasEntitlement(Long userId, Long productId);

    boolean hasEntitlementByCode(Long userId, String productCode);

    UserEntitlementDomain grant(Long userId, Long productId, String source, Long actorId);
}
