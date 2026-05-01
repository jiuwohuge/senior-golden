package cn.nine.pros.post.biz.service.clients;

import cn.nine.commons.feign.bridge.core.IFeignClient;
import cn.nine.pros.post.client.model.db.FoodDTO;

/**
 * ${classComments} FeignClient
 *
 * @author Administrator
 */
public interface FoodFeignClient extends IFeignClient<Long, FoodDTO> {
}