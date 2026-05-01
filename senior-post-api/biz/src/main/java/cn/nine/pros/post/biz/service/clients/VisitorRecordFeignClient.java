package cn.nine.pros.post.biz.service.clients;

import cn.nine.commons.feign.bridge.core.IFeignClient;
import cn.nine.pros.post.client.model.db.VisitorRecordDTO;

/**
 * 访客记录表 FeignClient
 *
 * @author Administrator
 */
public interface VisitorRecordFeignClient extends IFeignClient<Long, VisitorRecordDTO> {
}