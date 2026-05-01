package cn.nine.pros.post.biz.service.clients;

import cn.nine.commons.feign.bridge.core.IFeignClient;
import cn.nine.pros.post.client.model.db.PostcardCommentDTO;

/**
 * 明信片评论表 FeignClient
 *
 * @author Administrator
 */
public interface PostcardCommentFeignClient extends IFeignClient<Long, PostcardCommentDTO> {
}