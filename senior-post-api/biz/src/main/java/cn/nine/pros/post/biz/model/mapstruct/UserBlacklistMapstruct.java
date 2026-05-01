package cn.nine.pros.post.biz.model.mapstruct;

import cn.nine.commons.feign.bridge.core.CommonMapper;
import cn.nine.pros.post.biz.model.domain.UserBlacklistDomain;
import cn.nine.pros.post.client.model.db.UserBlacklistDTO;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

/**
 * 用户黑名单表 Mapper
 *
 * @author Administrator
 */
@Mapper(componentModel = "spring")
public interface UserBlacklistMapstruct extends CommonMapper<UserBlacklistDomain, UserBlacklistDTO> {

    UserBlacklistMapstruct INSTANCE = Mappers.getMapper(UserBlacklistMapstruct.class);

}