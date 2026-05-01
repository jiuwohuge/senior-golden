package cn.nine.pros.post.biz.model.mapstruct;

import cn.nine.commons.feign.bridge.core.CommonMapper;
import cn.nine.pros.post.biz.model.domain.UserTagDomain;
import cn.nine.pros.post.client.model.db.UserTagDTO;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

/**
 * 用户兴趣标签关联表 Mapper
 *
 * @author Administrator
 */
@Mapper(componentModel = "spring")
public interface UserTagMapstruct extends CommonMapper<UserTagDomain, UserTagDTO> {

    UserTagMapstruct INSTANCE = Mappers.getMapper(UserTagMapstruct.class);

}