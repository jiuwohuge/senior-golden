package cn.nine.pros.post.biz.service.clients.impl;

import cn.nine.commons.feign.bridge.mybatis.AbstractMybatisFeignClient;
import cn.nine.pros.post.biz.model.domain.AdminOperationDomain;
import cn.nine.pros.post.biz.model.mapstruct.AdminOperationMapstruct;
import cn.nine.pros.post.biz.service.clients.AdminOperationFeignClient;
import cn.nine.pros.post.client.model.db.AdminOperationDTO;
import org.springframework.stereotype.Service;

/**
 * 管理员操作日志表 FeignResource
 *
 * @author Administrator
 */
@Service
public class AdminOperationFeignResource extends AbstractMybatisFeignClient<Long, AdminOperationDomain, AdminOperationDTO,
        AdminOperationMapstruct> implements AdminOperationFeignClient {


}