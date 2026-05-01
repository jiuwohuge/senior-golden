package cn.nine.pros.post.biz.service.clients;

import cn.nine.commons.feign.bridge.core.IFeignClient;
import cn.nine.pros.post.client.model.db.CountryDTO;

/**
 * 国家地区表 FeignClient
 *
 * @author Administrator
 */
public interface CountryFeignClient extends IFeignClient<Integer, CountryDTO> {
}