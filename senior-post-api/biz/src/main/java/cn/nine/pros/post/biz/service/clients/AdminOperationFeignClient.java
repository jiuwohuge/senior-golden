package cn.nine.pros.post.biz.service.clients;

import cn.nine.commons.feign.bridge.core.IFeignClient;
import cn.nine.pros.post.client.model.db.AdminOperationDTO;

/**
 * 管理员操作日志表 FeignClient
 *
 * @author Administrator
 */
public interface AdminOperationFeignClient extends IFeignClient<Long, AdminOperationDTO> {
}