package cn.nine.pros.post.biz.service.clients;

import cn.nine.commons.feign.bridge.core.IFeignClient;
import cn.nine.pros.post.client.model.db.ImConversationDTO;

/**
 * IM会话表（腾讯IM） FeignClient
 *
 * @author Administrator
 */
public interface ImConversationFeignClient extends IFeignClient<Long, ImConversationDTO> {
}