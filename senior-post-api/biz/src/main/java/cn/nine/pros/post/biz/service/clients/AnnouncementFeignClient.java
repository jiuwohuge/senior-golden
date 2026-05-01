package cn.nine.pros.post.biz.service.clients;

import cn.nine.commons.feign.bridge.core.IFeignClient;
import cn.nine.pros.post.client.model.db.AnnouncementDTO;

/**
 * 系统公告表 FeignClient
 *
 * @author Administrator
 */
public interface AnnouncementFeignClient extends IFeignClient<Integer, AnnouncementDTO> {
}