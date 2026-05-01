package cn.nine.pros.post.biz.service.clients;

import cn.nine.commons.feign.bridge.core.IFeignClient;
import cn.nine.pros.post.client.model.db.ExceptionDTO;

/**
 * 系统异常日志表 FeignClient
 *
 * @author Administrator
 */
public interface ExceptionFeignClient extends IFeignClient<Long, ExceptionDTO> {
}