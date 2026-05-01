package cn.nine.pros.post.biz.model.mapstruct;

import cn.nine.commons.feign.bridge.core.CommonMapper;
import cn.nine.pros.post.biz.model.domain.TagDomain;
import cn.nine.pros.post.client.model.db.TagDTO;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

/**
 * 兴趣标签表 Mapper
 *
 * @author Administrator
 */
@Mapper(componentModel = "spring")
public interface TagMapstruct extends CommonMapper<TagDomain, TagDTO> {

    TagMapstruct INSTANCE = Mappers.getMapper(TagMapstruct.class);

}