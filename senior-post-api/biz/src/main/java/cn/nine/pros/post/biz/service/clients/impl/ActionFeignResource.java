package cn.nine.pros.post.biz.service.clients.impl;

import cn.nine.commons.feign.bridge.mybatis.AbstractMybatisFeignClient;
import cn.nine.pros.post.biz.model.domain.ActionDomain;
import cn.nine.pros.post.biz.model.mapstruct.ActionMapstruct;
import cn.nine.pros.post.biz.service.clients.ActionFeignClient;
import cn.nine.pros.post.client.model.db.ActionDTO;
import org.springframework.stereotype.Service;

/**
 * 用户行为日志（发布/寄信等） FeignResource
 *
 * @author Administrator
 */
@Service
public class ActionFeignResource extends AbstractMybatisFeignClient<Long, ActionDomain, ActionDTO,
        ActionMapstruct> implements ActionFeignClient {


}