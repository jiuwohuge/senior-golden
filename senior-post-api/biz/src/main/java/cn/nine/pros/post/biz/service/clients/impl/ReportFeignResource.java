package cn.nine.pros.post.biz.service.clients.impl;

import cn.nine.commons.feign.bridge.mybatis.AbstractMybatisFeignClient;
import cn.nine.pros.post.biz.model.domain.ReportDomain;
import cn.nine.pros.post.biz.model.mapstruct.ReportMapstruct;
import cn.nine.pros.post.biz.service.clients.ReportFeignClient;
import cn.nine.pros.post.client.model.db.ReportDTO;
import org.springframework.stereotype.Service;

/**
 * 举报工单表 FeignResource
 *
 * @author Administrator
 */
@Service
public class ReportFeignResource extends AbstractMybatisFeignClient<Long, ReportDomain, ReportDTO,
        ReportMapstruct> implements ReportFeignClient {


}