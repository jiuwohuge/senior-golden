package cn.nine.pros.post.biz.model.mapstruct;

import cn.nine.commons.feign.bridge.core.CommonMapper;
import cn.nine.pros.post.biz.model.domain.AdminUserDomain;
import cn.nine.pros.post.client.model.db.AdminUserDTO;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

/**
 * 管理员表 Mapper
 *
 * @author Administrator
 */
@Mapper(componentModel = "spring")
public interface AdminUserMapstruct extends CommonMapper<AdminUserDomain, AdminUserDTO> {

    AdminUserMapstruct INSTANCE = Mappers.getMapper(AdminUserMapstruct.class);

}