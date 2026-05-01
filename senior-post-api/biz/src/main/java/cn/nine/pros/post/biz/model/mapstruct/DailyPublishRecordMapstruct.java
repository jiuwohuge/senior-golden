package cn.nine.pros.post.biz.model.mapstruct;

import cn.nine.commons.feign.bridge.core.CommonMapper;
import cn.nine.pros.post.biz.model.domain.DailyPublishRecordDomain;
import cn.nine.pros.post.client.model.db.DailyPublishRecordDTO;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

/**
 * 每日发布记录表 Mapper
 *
 * @author Administrator
 */
@Mapper(componentModel = "spring")
public interface DailyPublishRecordMapstruct extends CommonMapper<DailyPublishRecordDomain, DailyPublishRecordDTO> {

    DailyPublishRecordMapstruct INSTANCE = Mappers.getMapper(DailyPublishRecordMapstruct.class);

}