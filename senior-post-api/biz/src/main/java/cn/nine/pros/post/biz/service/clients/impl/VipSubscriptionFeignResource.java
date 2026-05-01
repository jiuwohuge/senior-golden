package cn.nine.pros.post.biz.service.clients.impl;

import cn.nine.commons.feign.bridge.mybatis.AbstractMybatisFeignClient;
import cn.nine.pros.post.biz.model.domain.VipSubscriptionDomain;
import cn.nine.pros.post.biz.model.mapstruct.VipSubscriptionMapstruct;
import cn.nine.pros.post.biz.service.clients.VipSubscriptionFeignClient;
import cn.nine.pros.post.client.model.db.VipSubscriptionDTO;
import org.springframework.stereotype.Service;

/**
 * VIP订阅记录表 FeignResource
 *
 * @author Administrator
 */
@Service
public class VipSubscriptionFeignResource extends AbstractMybatisFeignClient<Long, VipSubscriptionDomain, VipSubscriptionDTO,
        VipSubscriptionMapstruct> implements VipSubscriptionFeignClient {


}