package cn.nine.pros.post.biz.service.clients;

import cn.nine.commons.feign.bridge.core.IFeignClient;
import cn.nine.pros.post.client.model.db.LetterDTO;

/**
 * 信件表（挂号信/平邮） FeignClient
 *
 * @author Administrator
 */
public interface LetterFeignClient extends IFeignClient<Long, LetterDTO> {
}