package cn.nine.pros.post.biz.service.clients;

import cn.nine.commons.feign.bridge.core.IFeignClient;
import cn.nine.pros.post.client.model.db.UserBlacklistDTO;

/**
 * 用户黑名单表 FeignClient
 *
 * @author Administrator
 */
public interface UserBlacklistFeignClient extends IFeignClient<Long, UserBlacklistDTO> {
}