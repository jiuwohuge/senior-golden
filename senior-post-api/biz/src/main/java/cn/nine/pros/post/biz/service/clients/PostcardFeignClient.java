package cn.nine.pros.post.biz.service.clients;

import cn.nine.commons.feign.bridge.core.IFeignClient;
import cn.nine.pros.post.client.model.db.PostcardDTO;

/**
 * 明信片墙表（用户发布的公开明信片） FeignClient
 *
 * @author Administrator
 */
public interface PostcardFeignClient extends IFeignClient<Long, PostcardDTO> {
}