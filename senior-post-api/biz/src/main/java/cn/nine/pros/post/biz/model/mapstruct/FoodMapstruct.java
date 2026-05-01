package cn.nine.pros.post.biz.model.mapstruct;

import cn.nine.commons.feign.bridge.core.CommonMapper;
import cn.nine.pros.post.biz.model.domain.FoodDomain;
import cn.nine.pros.post.client.model.db.FoodDTO;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

/**
 * ${classComments} Mapper
 *
 * @author Administrator
 */
@Mapper(componentModel = "spring")
public interface FoodMapstruct extends CommonMapper<FoodDomain, FoodDTO> {

    FoodMapstruct INSTANCE = Mappers.getMapper(FoodMapstruct.class);

}