package cn.nine.pros.post.biz.service.clients.impl;

import cn.nine.commons.feign.bridge.mybatis.AbstractMybatisFeignClient;
import cn.nine.pros.post.biz.model.domain.UserBlacklistDomain;
import cn.nine.pros.post.biz.model.mapstruct.UserBlacklistMapstruct;
import cn.nine.pros.post.biz.service.clients.UserBlacklistFeignClient;
import cn.nine.pros.post.client.model.db.UserBlacklistDTO;
import org.springframework.stereotype.Service;

/**
 * 用户黑名单表 FeignResource
 *
 * @author Administrator
 */
@Service
public class UserBlacklistFeignResource extends AbstractMybatisFeignClient<Long, UserBlacklistDomain, UserBlacklistDTO,
        UserBlacklistMapstruct> implements UserBlacklistFeignClient {


}