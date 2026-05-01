package cn.nine.pros.post.biz.service.clients;

import cn.nine.commons.feign.bridge.core.IFeignClient;
import cn.nine.pros.post.client.model.db.AdminUserDTO;

/**
 * 管理员表 FeignClient
 *
 * @author Administrator
 */
public interface AdminUserFeignClient extends IFeignClient<Long, AdminUserDTO> {
}