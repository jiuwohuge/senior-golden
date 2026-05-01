package cn.nine.pros.post.biz.service.clients.impl;

import cn.nine.commons.feign.bridge.mybatis.AbstractMybatisFeignClient;
import cn.nine.pros.post.biz.model.domain.LoginDomain;
import cn.nine.pros.post.biz.model.mapstruct.LoginMapstruct;
import cn.nine.pros.post.biz.service.clients.LoginFeignClient;
import cn.nine.pros.post.client.model.db.LoginDTO;
import org.springframework.stereotype.Service;

/**
 * 登录日志表 FeignResource
 *
 * @author Administrator
 */
@Service
public class LoginFeignResource extends AbstractMybatisFeignClient<Long, LoginDomain, LoginDTO,
        LoginMapstruct> implements LoginFeignClient {


}