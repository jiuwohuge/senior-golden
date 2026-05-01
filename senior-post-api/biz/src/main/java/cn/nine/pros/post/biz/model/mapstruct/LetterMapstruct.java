package cn.nine.pros.post.biz.model.mapstruct;

import cn.nine.commons.feign.bridge.core.CommonMapper;
import cn.nine.pros.post.biz.model.domain.LetterDomain;
import cn.nine.pros.post.client.model.db.LetterDTO;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

/**
 * 信件表（挂号信/平邮） Mapper
 *
 * @author Administrator
 */
@Mapper(componentModel = "spring")
public interface LetterMapstruct extends CommonMapper<LetterDomain, LetterDTO> {

    LetterMapstruct INSTANCE = Mappers.getMapper(LetterMapstruct.class);

}