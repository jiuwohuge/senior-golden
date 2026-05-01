package cn.nine.pros.post.biz.service.clients.impl;

import cn.nine.commons.feign.bridge.mybatis.AbstractMybatisFeignClient;
import cn.nine.pros.post.biz.model.domain.TagDomain;
import cn.nine.pros.post.biz.model.mapstruct.TagMapstruct;
import cn.nine.pros.post.biz.service.clients.TagFeignClient;
import cn.nine.pros.post.client.model.db.TagDTO;
import org.springframework.stereotype.Service;

/**
 * 兴趣标签表 FeignResource
 *
 * @author Administrator
 */
@Service
public class TagFeignResource extends AbstractMybatisFeignClient<Integer, TagDomain, TagDTO,
        TagMapstruct> implements TagFeignClient {


}