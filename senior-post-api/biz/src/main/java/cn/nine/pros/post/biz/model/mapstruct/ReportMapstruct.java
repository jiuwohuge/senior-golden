package cn.nine.pros.post.biz.model.mapstruct;

import cn.nine.commons.feign.bridge.core.CommonMapper;
import cn.nine.pros.post.biz.model.domain.ReportDomain;
import cn.nine.pros.post.client.model.db.ReportDTO;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

/**
 * 举报工单表 Mapper
 *
 * @author Administrator
 */
@Mapper(componentModel = "spring")
public interface ReportMapstruct extends CommonMapper<ReportDomain, ReportDTO> {

    ReportMapstruct INSTANCE = Mappers.getMapper(ReportMapstruct.class);

}