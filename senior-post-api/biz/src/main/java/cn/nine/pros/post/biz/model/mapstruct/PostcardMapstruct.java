package cn.nine.pros.post.biz.model.mapstruct;

import cn.nine.commons.feign.bridge.core.CommonMapper;
import cn.nine.pros.post.biz.model.domain.PostcardDomain;
import cn.nine.pros.post.client.model.db.PostcardDTO;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

/**
 * 明信片墙表（用户发布的公开明信片） Mapper
 *
 * @author Administrator
 */
@Mapper(componentModel = "spring")
public interface PostcardMapstruct extends CommonMapper<PostcardDomain, PostcardDTO> {

    PostcardMapstruct INSTANCE = Mappers.getMapper(PostcardMapstruct.class);

}