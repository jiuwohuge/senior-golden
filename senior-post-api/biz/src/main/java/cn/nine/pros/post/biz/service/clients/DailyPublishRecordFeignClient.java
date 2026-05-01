package cn.nine.pros.post.biz.service.clients;

import cn.nine.commons.feign.bridge.core.IFeignClient;
import cn.nine.pros.post.client.model.db.DailyPublishRecordDTO;

/**
 * 每日发布记录表 FeignClient
 *
 * @author Administrator
 */
public interface DailyPublishRecordFeignClient extends IFeignClient<Long, DailyPublishRecordDTO> {
}