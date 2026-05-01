package cn.nine.pros.post.biz.service.clients;

import cn.nine.commons.feign.bridge.core.IFeignClient;
import cn.nine.pros.post.client.model.db.TagDTO;

/**
 * 兴趣标签表 FeignClient
 *
 * @author Administrator
 */
public interface TagFeignClient extends IFeignClient<Integer, TagDTO> {
}