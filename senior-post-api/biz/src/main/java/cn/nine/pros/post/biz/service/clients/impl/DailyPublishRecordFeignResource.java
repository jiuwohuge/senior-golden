package cn.nine.pros.post.biz.service.clients.impl;

import cn.nine.commons.feign.bridge.mybatis.AbstractMybatisFeignClient;
import cn.nine.pros.post.biz.model.domain.DailyPublishRecordDomain;
import cn.nine.pros.post.biz.model.mapstruct.DailyPublishRecordMapstruct;
import cn.nine.pros.post.biz.service.clients.DailyPublishRecordFeignClient;
import cn.nine.pros.post.client.model.db.DailyPublishRecordDTO;
import org.springframework.stereotype.Service;

/**
 * 每日发布记录表 FeignResource
 *
 * @author Administrator
 */
@Service
public class DailyPublishRecordFeignResource extends AbstractMybatisFeignClient<Long, DailyPublishRecordDomain, DailyPublishRecordDTO,
        DailyPublishRecordMapstruct> implements DailyPublishRecordFeignClient {


}