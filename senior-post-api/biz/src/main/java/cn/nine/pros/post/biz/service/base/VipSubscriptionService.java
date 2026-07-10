package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.VipSubscriptionDomain;
import com.baomidou.mybatisplus.extension.service.IService;
import cn.nine.pros.post.client.model.db.VipSubscriptionDTO;

import java.util.List;

/**
 * VIP订阅记录表 Service
 *
 * @author Administrator
 */
public interface VipSubscriptionService extends IService<VipSubscriptionDomain> {

    void upsert(VipSubscriptionDTO vipSubscriptionDTO);

    VipSubscriptionDTO findById(Long id);

    void delByIds(List<Long> ids);

    long countActive();

}