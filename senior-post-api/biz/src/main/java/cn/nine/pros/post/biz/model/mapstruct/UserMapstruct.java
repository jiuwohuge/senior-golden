package cn.nine.pros.post.biz.model.mapstruct;

import cn.nine.commons.feign.bridge.core.CommonMapper;
import cn.nine.pros.post.biz.model.domain.UserDomain;
import cn.nine.pros.post.client.model.db.UserDTO;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

/**
 * 用户主表 Mapper
 *
 * @author Administrator
 */
@Mapper(componentModel = "spring")
public interface UserMapstruct extends CommonMapper<UserDomain, UserDTO> {

    UserMapstruct INSTANCE = Mappers.getMapper(UserMapstruct.class);

}