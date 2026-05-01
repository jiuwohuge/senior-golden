package cn.nine.pros.post.biz.service.clients.impl;

import cn.nine.commons.feign.bridge.mybatis.AbstractMybatisFeignClient;
import cn.nine.pros.post.biz.model.domain.UserDeviceDomain;
import cn.nine.pros.post.biz.model.mapstruct.UserDeviceMapstruct;
import cn.nine.pros.post.biz.service.clients.UserDeviceFeignClient;
import cn.nine.pros.post.client.model.db.UserDeviceDTO;
import org.springframework.stereotype.Service;

/**
 * 用户设备记录表（用于风控/拉黑/防刷） FeignResource
 *
 * @author Administrator
 */
@Service
public class UserDeviceFeignResource extends AbstractMybatisFeignClient<Long, UserDeviceDomain, UserDeviceDTO,
        UserDeviceMapstruct> implements UserDeviceFeignClient {


}