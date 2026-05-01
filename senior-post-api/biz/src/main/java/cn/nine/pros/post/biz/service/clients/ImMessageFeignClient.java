package cn.nine.pros.post.biz.service.clients;

import cn.nine.commons.feign.bridge.core.IFeignClient;
import cn.nine.pros.post.client.model.db.ImMessageDTO;

/**
 * IM消息表 FeignClient
 *
 * @author Administrator
 */
public interface ImMessageFeignClient extends IFeignClient<Long, ImMessageDTO> {
}