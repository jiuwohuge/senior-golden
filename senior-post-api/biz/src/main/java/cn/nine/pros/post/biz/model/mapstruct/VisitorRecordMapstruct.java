package cn.nine.pros.post.biz.model.mapstruct;

import cn.nine.commons.feign.bridge.core.CommonMapper;
import cn.nine.pros.post.biz.model.domain.VisitorRecordDomain;
import cn.nine.pros.post.client.model.db.VisitorRecordDTO;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

/**
 * 访客记录表 Mapper
 *
 * @author Administrator
 */
@Mapper(componentModel = "spring")
public interface VisitorRecordMapstruct extends CommonMapper<VisitorRecordDomain, VisitorRecordDTO> {

    VisitorRecordMapstruct INSTANCE = Mappers.getMapper(VisitorRecordMapstruct.class);

}