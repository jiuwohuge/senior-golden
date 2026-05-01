package cn.nine.pros.post.biz.model.mapstruct;

import cn.nine.commons.feign.bridge.core.CommonMapper;
import cn.nine.pros.post.biz.model.domain.PostcardCommentDomain;
import cn.nine.pros.post.client.model.db.PostcardCommentDTO;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

/**
 * 明信片评论表 Mapper
 *
 * @author Administrator
 */
@Mapper(componentModel = "spring")
public interface PostcardCommentMapstruct extends CommonMapper<PostcardCommentDomain, PostcardCommentDTO> {

    PostcardCommentMapstruct INSTANCE = Mappers.getMapper(PostcardCommentMapstruct.class);

}