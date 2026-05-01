package cn.nine.pros.post.biz.service.clients;

import cn.nine.commons.feign.bridge.core.IFeignClient;
import cn.nine.pros.post.client.model.db.StampTransactionDTO;

/**
 * 邮票变更流水日志 FeignClient
 *
 * @author Administrator
 */
public interface StampTransactionFeignClient extends IFeignClient<Long, StampTransactionDTO> {
}