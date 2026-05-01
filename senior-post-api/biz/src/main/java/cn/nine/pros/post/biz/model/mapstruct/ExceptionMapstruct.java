package cn.nine.pros.post.biz.model.mapstruct;

import cn.nine.commons.feign.bridge.core.CommonMapper;
import cn.nine.pros.post.biz.model.domain.ExceptionDomain;
import cn.nine.pros.post.client.model.db.ExceptionDTO;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

/**
 * 系统异常日志表 Mapper
 *
 * @author Administrator
 */
@Mapper(componentModel = "spring")
public interface ExceptionMapstruct extends CommonMapper<ExceptionDomain, ExceptionDTO> {

    ExceptionMapstruct INSTANCE = Mappers.getMapper(ExceptionMapstruct.class);

}