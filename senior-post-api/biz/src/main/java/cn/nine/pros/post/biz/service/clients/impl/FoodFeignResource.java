package cn.nine.pros.post.biz.service.clients.impl;

import cn.nine.commons.feign.bridge.mybatis.AbstractMybatisFeignClient;
import cn.nine.pros.post.biz.model.domain.FoodDomain;
import cn.nine.pros.post.biz.model.mapstruct.FoodMapstruct;
import cn.nine.pros.post.biz.service.clients.FoodFeignClient;
import cn.nine.pros.post.client.model.db.FoodDTO;
import org.springframework.stereotype.Service;

/**
 * ${classComments} FeignResource
 *
 * @author Administrator
 */
@Service
public class FoodFeignResource extends AbstractMybatisFeignClient<Long, FoodDomain, FoodDTO,
        FoodMapstruct> implements FoodFeignClient {


}