package cn.nine.pros.post.biz.service.clients.impl;

import cn.nine.commons.feign.bridge.mybatis.AbstractMybatisFeignClient;
import cn.nine.pros.post.biz.model.domain.ConfigDomain;
import cn.nine.pros.post.biz.model.mapstruct.ConfigMapstruct;
import cn.nine.pros.post.biz.service.clients.ConfigFeignClient;
import cn.nine.pros.post.client.model.db.ConfigDTO;
import org.springframework.stereotype.Service;

/**
 * 系统配置表 FeignResource
 *
 * @author Administrator
 */
@Service
public class ConfigFeignResource extends AbstractMybatisFeignClient<Integer, ConfigDomain, ConfigDTO,
        ConfigMapstruct> implements ConfigFeignClient {


}