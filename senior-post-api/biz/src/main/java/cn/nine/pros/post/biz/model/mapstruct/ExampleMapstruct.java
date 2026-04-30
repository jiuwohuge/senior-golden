package cn.nine.pros.post.biz.model.mapstruct;

import cn.nine.commons.feign.bridge.core.CommonMapper;
import cn.nine.pros.post.biz.model.domain.ExampleDomain;
import cn.nine.pros.post.client.model.db.ExampleDTO;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

/**
 * ${classComments} Mapper
 *
 * @author Administrator
 */
@Mapper(componentModel = "spring")
public interface ExampleMapstruct extends CommonMapper<ExampleDomain, ExampleDTO> {

    ExampleMapstruct INSTANCE = Mappers.getMapper(ExampleMapstruct.class);

}
