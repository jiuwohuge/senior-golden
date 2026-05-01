package cn.nine.pros.post.biz.service.clients.impl;

import cn.nine.commons.feign.bridge.mybatis.AbstractMybatisFeignClient;
import cn.nine.pros.post.biz.model.domain.CountryDomain;
import cn.nine.pros.post.biz.model.mapstruct.CountryMapstruct;
import cn.nine.pros.post.biz.service.clients.CountryFeignClient;
import cn.nine.pros.post.client.model.db.CountryDTO;
import org.springframework.stereotype.Service;

/**
 * 国家地区表 FeignResource
 *
 * @author Administrator
 */
@Service
public class CountryFeignResource extends AbstractMybatisFeignClient<Integer, CountryDomain, CountryDTO,
        CountryMapstruct> implements CountryFeignClient {


}