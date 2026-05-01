package cn.nine.pros.post.biz.service.clients.impl;

import cn.nine.commons.feign.bridge.mybatis.AbstractMybatisFeignClient;
import cn.nine.pros.post.biz.model.domain.VisitorRecordDomain;
import cn.nine.pros.post.biz.model.mapstruct.VisitorRecordMapstruct;
import cn.nine.pros.post.biz.service.clients.VisitorRecordFeignClient;
import cn.nine.pros.post.client.model.db.VisitorRecordDTO;
import org.springframework.stereotype.Service;

/**
 * 访客记录表 FeignResource
 *
 * @author Administrator
 */
@Service
public class VisitorRecordFeignResource extends AbstractMybatisFeignClient<Long, VisitorRecordDomain, VisitorRecordDTO,
        VisitorRecordMapstruct> implements VisitorRecordFeignClient {


}