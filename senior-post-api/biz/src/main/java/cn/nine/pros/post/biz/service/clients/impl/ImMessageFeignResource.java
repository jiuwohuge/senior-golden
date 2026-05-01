package cn.nine.pros.post.biz.service.clients.impl;

import cn.nine.commons.feign.bridge.mybatis.AbstractMybatisFeignClient;
import cn.nine.pros.post.biz.model.domain.ImMessageDomain;
import cn.nine.pros.post.biz.model.mapstruct.ImMessageMapstruct;
import cn.nine.pros.post.biz.service.clients.ImMessageFeignClient;
import cn.nine.pros.post.client.model.db.ImMessageDTO;
import org.springframework.stereotype.Service;

/**
 * IM消息表 FeignResource
 *
 * @author Administrator
 */
@Service
public class ImMessageFeignResource extends AbstractMybatisFeignClient<Long, ImMessageDomain, ImMessageDTO,
        ImMessageMapstruct> implements ImMessageFeignClient {


}