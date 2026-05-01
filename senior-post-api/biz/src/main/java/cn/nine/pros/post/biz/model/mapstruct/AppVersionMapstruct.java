package cn.nine.pros.post.biz.model.mapstruct;

import cn.nine.commons.feign.bridge.core.CommonMapper;
import cn.nine.pros.post.biz.model.domain.AppVersionDomain;
import cn.nine.pros.post.client.model.db.AppVersionDTO;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

/**
 * App版本控制表 Mapper
 *
 * @author Administrator
 */
@Mapper(componentModel = "spring")
public interface AppVersionMapstruct extends CommonMapper<AppVersionDomain, AppVersionDTO> {

    AppVersionMapstruct INSTANCE = Mappers.getMapper(AppVersionMapstruct.class);

}