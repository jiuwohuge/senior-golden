package cn.nine.pros.post.biz.model.mapstruct;

import cn.nine.commons.feign.bridge.core.CommonMapper;
import cn.nine.pros.post.biz.model.domain.CountryDomain;
import cn.nine.pros.post.client.model.db.CountryDTO;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

/**
 * 国家地区表 Mapper
 *
 * @author Administrator
 */
@Mapper(componentModel = "spring")
public interface CountryMapstruct extends CommonMapper<CountryDomain, CountryDTO> {

    CountryMapstruct INSTANCE = Mappers.getMapper(CountryMapstruct.class);

}