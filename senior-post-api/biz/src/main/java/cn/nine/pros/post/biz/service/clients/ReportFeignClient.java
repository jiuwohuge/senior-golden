package cn.nine.pros.post.biz.service.clients;

import cn.nine.commons.feign.bridge.core.IFeignClient;
import cn.nine.pros.post.client.model.db.ReportDTO;

/**
 * 举报工单表 FeignClient
 *
 * @author Administrator
 */
public interface ReportFeignClient extends IFeignClient<Long, ReportDTO> {
}