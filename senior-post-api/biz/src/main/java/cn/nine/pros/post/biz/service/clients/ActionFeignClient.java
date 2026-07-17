package cn.nine.pros.post.biz.service.clients;

import cn.nine.commons.feign.bridge.core.IFeignClient;
import cn.nine.pros.post.client.model.db.ActionDTO;

/**
 * 用户行为日志（发布/寄信等） FeignClient
 *
 * @author Administrator
 */
public interface ActionFeignClient extends IFeignClient<Long, ActionDTO> {
}