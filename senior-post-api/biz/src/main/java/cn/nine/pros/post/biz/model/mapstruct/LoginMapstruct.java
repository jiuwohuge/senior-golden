package cn.nine.pros.post.biz.model.mapstruct;

import cn.nine.commons.feign.bridge.core.CommonMapper;
import cn.nine.pros.post.biz.model.domain.LoginDomain;
import cn.nine.pros.post.client.model.db.LoginDTO;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

/**
 * 登录日志表 Mapper
 *
 * @author Administrator
 */
@Mapper(componentModel = "spring")
public interface LoginMapstruct extends CommonMapper<LoginDomain, LoginDTO> {

    LoginMapstruct INSTANCE = Mappers.getMapper(LoginMapstruct.class);

}