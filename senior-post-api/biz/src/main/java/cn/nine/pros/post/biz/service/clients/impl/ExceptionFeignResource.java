package cn.nine.pros.post.biz.service.clients.impl;

import cn.nine.commons.feign.bridge.mybatis.AbstractMybatisFeignClient;
import cn.nine.pros.post.biz.model.domain.ExceptionDomain;
import cn.nine.pros.post.biz.model.mapstruct.ExceptionMapstruct;
import cn.nine.pros.post.biz.service.clients.ExceptionFeignClient;
import cn.nine.pros.post.client.model.db.ExceptionDTO;
import org.springframework.stereotype.Service;

/**
 * 系统异常日志表 FeignResource
 *
 * @author Administrator
 */
@Service
public class ExceptionFeignResource extends AbstractMybatisFeignClient<Long, ExceptionDomain, ExceptionDTO,
        ExceptionMapstruct> implements ExceptionFeignClient {


}