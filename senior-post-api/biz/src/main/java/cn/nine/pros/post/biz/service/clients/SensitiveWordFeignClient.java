package cn.nine.pros.post.biz.service.clients;

import cn.nine.commons.feign.bridge.core.IFeignClient;
import cn.nine.pros.post.client.model.db.SensitiveWordDTO;

/**
 * 敏感词库表 FeignClient
 *
 * @author Administrator
 */
public interface SensitiveWordFeignClient extends IFeignClient<Integer, SensitiveWordDTO> {
}