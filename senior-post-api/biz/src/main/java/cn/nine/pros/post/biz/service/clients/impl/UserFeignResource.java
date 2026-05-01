package cn.nine.pros.post.biz.service.clients.impl;

import cn.nine.commons.feign.bridge.mybatis.AbstractMybatisFeignClient;
import cn.nine.pros.post.biz.model.domain.UserDomain;
import cn.nine.pros.post.biz.model.mapstruct.UserMapstruct;
import cn.nine.pros.post.biz.service.clients.UserFeignClient;
import cn.nine.pros.post.client.model.db.UserDTO;
import org.springframework.stereotype.Service;

/**
 * 用户主表 FeignResource
 *
 * @author Administrator
 */
@Service
public class UserFeignResource extends AbstractMybatisFeignClient<Long, UserDomain, UserDTO,
        UserMapstruct> implements UserFeignClient {


}