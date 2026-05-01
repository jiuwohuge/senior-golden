package cn.nine.pros.post.biz.service.clients;

import cn.nine.commons.feign.bridge.core.IFeignClient;
import cn.nine.pros.post.client.model.db.AppVersionDTO;

/**
 * App版本控制表 FeignClient
 *
 * @author Administrator
 */
public interface AppVersionFeignClient extends IFeignClient<Integer, AppVersionDTO> {
}