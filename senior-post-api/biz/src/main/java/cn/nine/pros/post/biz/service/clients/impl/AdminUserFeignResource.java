package cn.nine.pros.post.biz.service.clients.impl;

import cn.nine.commons.feign.bridge.mybatis.AbstractMybatisFeignClient;
import cn.nine.pros.post.biz.model.domain.AdminUserDomain;
import cn.nine.pros.post.biz.model.mapstruct.AdminUserMapstruct;
import cn.nine.pros.post.biz.service.clients.AdminUserFeignClient;
import cn.nine.pros.post.client.model.db.AdminUserDTO;
import org.springframework.stereotype.Service;

/**
 * 管理员表 FeignResource
 *
 * @author Administrator
 */
@Service
public class AdminUserFeignResource extends AbstractMybatisFeignClient<Long, AdminUserDomain, AdminUserDTO,
        AdminUserMapstruct> implements AdminUserFeignClient {


}