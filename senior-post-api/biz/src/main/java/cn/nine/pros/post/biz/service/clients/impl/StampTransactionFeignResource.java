package cn.nine.pros.post.biz.service.clients.impl;

import cn.nine.commons.feign.bridge.mybatis.AbstractMybatisFeignClient;
import cn.nine.pros.post.biz.model.domain.StampTransactionDomain;
import cn.nine.pros.post.biz.model.mapstruct.StampTransactionMapstruct;
import cn.nine.pros.post.biz.service.clients.StampTransactionFeignClient;
import cn.nine.pros.post.client.model.db.StampTransactionDTO;
import org.springframework.stereotype.Service;

/**
 * 邮票变更流水日志 FeignResource
 *
 * @author Administrator
 */
@Service
public class StampTransactionFeignResource extends AbstractMybatisFeignClient<Long, StampTransactionDomain, StampTransactionDTO,
        StampTransactionMapstruct> implements StampTransactionFeignClient {


}