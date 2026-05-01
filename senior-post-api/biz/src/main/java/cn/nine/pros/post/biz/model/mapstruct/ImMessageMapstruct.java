package cn.nine.pros.post.biz.model.mapstruct;

import cn.nine.commons.feign.bridge.core.CommonMapper;
import cn.nine.pros.post.biz.model.domain.ImMessageDomain;
import cn.nine.pros.post.client.model.db.ImMessageDTO;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

/**
 * IM消息表 Mapper
 *
 * @author Administrator
 */
@Mapper(componentModel = "spring")
public interface ImMessageMapstruct extends CommonMapper<ImMessageDomain, ImMessageDTO> {

    ImMessageMapstruct INSTANCE = Mappers.getMapper(ImMessageMapstruct.class);

}