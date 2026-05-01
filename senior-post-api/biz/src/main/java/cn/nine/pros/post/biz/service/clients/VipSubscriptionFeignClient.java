package cn.nine.pros.post.biz.service.clients;

import cn.nine.commons.feign.bridge.core.IFeignClient;
import cn.nine.pros.post.client.model.db.VipSubscriptionDTO;

/**
 * VIP订阅记录表 FeignClient
 *
 * @author Administrator
 */
public interface VipSubscriptionFeignClient extends IFeignClient<Long, VipSubscriptionDTO> {
}