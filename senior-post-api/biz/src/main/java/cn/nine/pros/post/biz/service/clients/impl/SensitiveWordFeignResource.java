package cn.nine.pros.post.biz.service.clients.impl;

import cn.nine.commons.feign.bridge.mybatis.AbstractMybatisFeignClient;
import cn.nine.pros.post.biz.model.domain.SensitiveWordDomain;
import cn.nine.pros.post.biz.model.mapstruct.SensitiveWordMapstruct;
import cn.nine.pros.post.biz.service.clients.SensitiveWordFeignClient;
import cn.nine.pros.post.client.model.db.SensitiveWordDTO;
import org.springframework.stereotype.Service;

/**
 * 敏感词库表 FeignResource
 *
 * @author Administrator
 */
@Service
public class SensitiveWordFeignResource extends AbstractMybatisFeignClient<Integer, SensitiveWordDomain, SensitiveWordDTO,
        SensitiveWordMapstruct> implements SensitiveWordFeignClient {


}