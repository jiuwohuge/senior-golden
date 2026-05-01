package cn.nine.pros.post.biz.service.clients.impl;

import cn.nine.commons.feign.bridge.mybatis.AbstractMybatisFeignClient;
import cn.nine.pros.post.biz.model.domain.UserTagDomain;
import cn.nine.pros.post.biz.model.mapstruct.UserTagMapstruct;
import cn.nine.pros.post.biz.service.clients.UserTagFeignClient;
import cn.nine.pros.post.client.model.db.UserTagDTO;
import org.springframework.stereotype.Service;

/**
 * 用户兴趣标签关联表 FeignResource
 *
 * @author Administrator
 */
@Service
public class UserTagFeignResource extends AbstractMybatisFeignClient<Long, UserTagDomain, UserTagDTO,
        UserTagMapstruct> implements UserTagFeignClient {


}