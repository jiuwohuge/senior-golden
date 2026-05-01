package cn.nine.pros.post.biz.model.mapstruct;

import cn.nine.commons.feign.bridge.core.CommonMapper;
import cn.nine.pros.post.biz.model.domain.StampTransactionDomain;
import cn.nine.pros.post.client.model.db.StampTransactionDTO;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

/**
 * 邮票变更流水日志 Mapper
 *
 * @author Administrator
 */
@Mapper(componentModel = "spring")
public interface StampTransactionMapstruct extends CommonMapper<StampTransactionDomain, StampTransactionDTO> {

    StampTransactionMapstruct INSTANCE = Mappers.getMapper(StampTransactionMapstruct.class);

}