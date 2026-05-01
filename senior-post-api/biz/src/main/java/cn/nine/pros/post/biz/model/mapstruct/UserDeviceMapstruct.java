package cn.nine.pros.post.biz.model.mapstruct;

import cn.nine.commons.feign.bridge.core.CommonMapper;
import cn.nine.pros.post.biz.model.domain.UserDeviceDomain;
import cn.nine.pros.post.client.model.db.UserDeviceDTO;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

/**
 * 用户设备记录表（用于风控/拉黑/防刷） Mapper
 *
 * @author Administrator
 */
@Mapper(componentModel = "spring")
public interface UserDeviceMapstruct extends CommonMapper<UserDeviceDomain, UserDeviceDTO> {

    UserDeviceMapstruct INSTANCE = Mappers.getMapper(UserDeviceMapstruct.class);

}