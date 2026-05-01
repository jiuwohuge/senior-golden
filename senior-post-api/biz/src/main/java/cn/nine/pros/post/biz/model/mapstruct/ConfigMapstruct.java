package cn.nine.pros.post.biz.model.mapstruct;

import cn.nine.commons.feign.bridge.core.CommonMapper;
import cn.nine.pros.post.biz.model.domain.ConfigDomain;
import cn.nine.pros.post.client.model.db.ConfigDTO;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

/**
 * 系统配置表 Mapper
 *
 * @author Administrator
 */
@Mapper(componentModel = "spring")
public interface ConfigMapstruct extends CommonMapper<ConfigDomain, ConfigDTO> {

    ConfigMapstruct INSTANCE = Mappers.getMapper(ConfigMapstruct.class);

}