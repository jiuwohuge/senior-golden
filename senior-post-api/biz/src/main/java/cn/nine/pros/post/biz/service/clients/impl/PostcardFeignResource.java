package cn.nine.pros.post.biz.service.clients.impl;

import cn.nine.commons.feign.bridge.mybatis.AbstractMybatisFeignClient;
import cn.nine.pros.post.biz.model.domain.PostcardDomain;
import cn.nine.pros.post.biz.model.mapstruct.PostcardMapstruct;
import cn.nine.pros.post.biz.service.clients.PostcardFeignClient;
import cn.nine.pros.post.client.model.db.PostcardDTO;
import org.springframework.stereotype.Service;

/**
 * 明信片墙表（用户发布的公开明信片） FeignResource
 *
 * @author Administrator
 */
@Service
public class PostcardFeignResource extends AbstractMybatisFeignClient<Long, PostcardDomain, PostcardDTO,
        PostcardMapstruct> implements PostcardFeignClient {


}