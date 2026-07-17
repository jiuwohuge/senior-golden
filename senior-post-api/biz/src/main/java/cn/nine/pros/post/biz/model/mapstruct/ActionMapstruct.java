package cn.nine.pros.post.biz.model.mapstruct;

import cn.nine.commons.feign.bridge.core.CommonMapper;
import cn.nine.pros.post.biz.model.domain.ActionDomain;
import cn.nine.pros.post.client.model.db.ActionDTO;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

/**
 * 用户行为日志（发布/寄信等） Mapper
 *
 * @author Administrator
 */
@Mapper(componentModel = "spring")
public interface ActionMapstruct extends CommonMapper<ActionDomain, ActionDTO> {

    ActionMapstruct INSTANCE = Mappers.getMapper(ActionMapstruct.class);

}