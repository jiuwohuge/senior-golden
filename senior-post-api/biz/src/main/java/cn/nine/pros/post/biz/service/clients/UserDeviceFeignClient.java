package cn.nine.pros.post.biz.service.clients;

import cn.nine.commons.feign.bridge.core.IFeignClient;
import cn.nine.pros.post.client.model.db.UserDeviceDTO;

/**
 * 用户设备记录表（用于风控/拉黑/防刷） FeignClient
 *
 * @author Administrator
 */
public interface UserDeviceFeignClient extends IFeignClient<Long, UserDeviceDTO> {
}