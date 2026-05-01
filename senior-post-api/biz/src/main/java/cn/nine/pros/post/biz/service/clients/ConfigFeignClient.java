package cn.nine.pros.post.biz.service.clients;

import cn.nine.commons.feign.bridge.core.IFeignClient;
import cn.nine.pros.post.client.model.db.ConfigDTO;

/**
 * 系统配置表 FeignClient
 *
 * @author Administrator
 */
public interface ConfigFeignClient extends IFeignClient<Integer, ConfigDTO> {
}