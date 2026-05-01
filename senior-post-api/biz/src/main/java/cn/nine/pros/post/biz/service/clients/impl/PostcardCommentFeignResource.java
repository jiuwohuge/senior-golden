package cn.nine.pros.post.biz.service.clients.impl;

import cn.nine.commons.feign.bridge.mybatis.AbstractMybatisFeignClient;
import cn.nine.pros.post.biz.model.domain.PostcardCommentDomain;
import cn.nine.pros.post.biz.model.mapstruct.PostcardCommentMapstruct;
import cn.nine.pros.post.biz.service.clients.PostcardCommentFeignClient;
import cn.nine.pros.post.client.model.db.PostcardCommentDTO;
import org.springframework.stereotype.Service;

/**
 * 明信片评论表 FeignResource
 *
 * @author Administrator
 */
@Service
public class PostcardCommentFeignResource extends AbstractMybatisFeignClient<Long, PostcardCommentDomain, PostcardCommentDTO,
        PostcardCommentMapstruct> implements PostcardCommentFeignClient {


}