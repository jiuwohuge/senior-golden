package cn.nine.pros.post.biz.model.mapstruct;

import cn.nine.commons.feign.bridge.core.CommonMapper;
import cn.nine.pros.post.biz.model.domain.AdminOperationDomain;
import cn.nine.pros.post.client.model.db.AdminOperationDTO;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

/**
 * 管理员操作日志表 Mapper
 *
 * @author Administrator
 */
@Mapper(componentModel = "spring")
public interface AdminOperationMapstruct extends CommonMapper<AdminOperationDomain, AdminOperationDTO> {

    AdminOperationMapstruct INSTANCE = Mappers.getMapper(AdminOperationMapstruct.class);

}