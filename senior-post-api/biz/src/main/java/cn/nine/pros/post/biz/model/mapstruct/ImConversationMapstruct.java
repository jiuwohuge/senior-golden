package cn.nine.pros.post.biz.model.mapstruct;

import cn.nine.commons.feign.bridge.core.CommonMapper;
import cn.nine.pros.post.biz.model.domain.ImConversationDomain;
import cn.nine.pros.post.client.model.db.ImConversationDTO;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

/**
 * IM会话表（腾讯IM） Mapper
 *
 * @author Administrator
 */
@Mapper(componentModel = "spring")
public interface ImConversationMapstruct extends CommonMapper<ImConversationDomain, ImConversationDTO> {

    ImConversationMapstruct INSTANCE = Mappers.getMapper(ImConversationMapstruct.class);

}