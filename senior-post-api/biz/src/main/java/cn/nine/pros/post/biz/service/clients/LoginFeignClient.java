package cn.nine.pros.post.biz.service.clients;

import cn.nine.commons.feign.bridge.core.IFeignClient;
import cn.nine.pros.post.client.model.db.LoginDTO;

/**
 * 登录日志表 FeignClient
 *
 * @author Administrator
 */
public interface LoginFeignClient extends IFeignClient<Long, LoginDTO> {
}