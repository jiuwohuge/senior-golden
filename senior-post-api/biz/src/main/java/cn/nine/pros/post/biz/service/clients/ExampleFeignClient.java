package cn.nine.pros.post.biz.service.clients;

import cn.nine.commons.feign.bridge.core.IFeignClient;
import cn.nine.pros.post.client.model.db.ExampleDTO;

/**
 * @Author JiuHu
 * @ClassName ExampleFeignClient
 * @Description TODO
 * @Date 2026/4/30 星期四 21:52
 * @Version 1.0
 */
public interface ExampleFeignClient extends IFeignClient<Long, ExampleDTO> {
}
