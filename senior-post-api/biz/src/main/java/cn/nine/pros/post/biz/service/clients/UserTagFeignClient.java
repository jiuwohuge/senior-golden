package cn.nine.pros.post.biz.service.clients;

import cn.nine.commons.feign.bridge.core.IFeignClient;
import cn.nine.pros.post.client.model.db.UserTagDTO;

/**
 * 用户兴趣标签关联表 FeignClient
 *
 * @author Administrator
 */
public interface UserTagFeignClient extends IFeignClient<Long, UserTagDTO> {
}