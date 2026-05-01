package cn.nine.pros.post.biz.service.clients;

import cn.nine.commons.feign.bridge.core.IFeignClient;
import cn.nine.pros.post.client.model.db.UserDTO;

/**
 * 用户主表 FeignClient
 *
 * @author Administrator
 */
public interface UserFeignClient extends IFeignClient<Long, UserDTO> {
}