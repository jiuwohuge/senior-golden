package cn.nine.pros.post.biz.model.mapstruct;

import cn.nine.commons.feign.bridge.core.CommonMapper;
import cn.nine.pros.post.biz.model.domain.VipSubscriptionDomain;
import cn.nine.pros.post.client.model.db.VipSubscriptionDTO;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

/**
 * VIP订阅记录表 Mapper
 *
 * @author Administrator
 */
@Mapper(componentModel = "spring")
public interface VipSubscriptionMapstruct extends CommonMapper<VipSubscriptionDomain, VipSubscriptionDTO> {

    VipSubscriptionMapstruct INSTANCE = Mappers.getMapper(VipSubscriptionMapstruct.class);

}