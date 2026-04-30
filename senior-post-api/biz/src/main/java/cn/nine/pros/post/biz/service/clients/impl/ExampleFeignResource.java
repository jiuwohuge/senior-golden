package cn.nine.pros.post.biz.service.clients.impl;

import cn.nine.commons.feign.bridge.mybatis.AbstractMybatisFeignClient;
import cn.nine.pros.post.biz.model.domain.ExampleDomain;
import cn.nine.pros.post.biz.model.mapstruct.ExampleMapstruct;
import cn.nine.pros.post.biz.service.clients.ExampleFeignClient;
import cn.nine.pros.post.client.model.db.ExampleDTO;
import org.springframework.stereotype.Service;

/**
 * @Author JiuHu
 * @ClassName ExampleFeignResource
 * @Description TODO
 * @Date 2026/4/30 星期四 21:54
 * @Version 1.0
 */
@Service
public class ExampleFeignResource extends AbstractMybatisFeignClient<Long, ExampleDomain, ExampleDTO,
        ExampleMapstruct> implements ExampleFeignClient {
}
