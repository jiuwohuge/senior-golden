package cn.nine.pros.post.biz.model.mapstruct;

import cn.nine.commons.feign.bridge.core.CommonMapper;
import cn.nine.pros.post.biz.model.domain.SensitiveWordDomain;
import cn.nine.pros.post.client.model.db.SensitiveWordDTO;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

/**
 * 敏感词库表 Mapper
 *
 * @author Administrator
 */
@Mapper(componentModel = "spring")
public interface SensitiveWordMapstruct extends CommonMapper<SensitiveWordDomain, SensitiveWordDTO> {

    SensitiveWordMapstruct INSTANCE = Mappers.getMapper(SensitiveWordMapstruct.class);

}