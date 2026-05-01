package cn.nine.pros.post.biz.service.clients.impl;

import cn.nine.commons.feign.bridge.mybatis.AbstractMybatisFeignClient;
import cn.nine.pros.post.biz.model.domain.ImConversationDomain;
import cn.nine.pros.post.biz.model.mapstruct.ImConversationMapstruct;
import cn.nine.pros.post.biz.service.clients.ImConversationFeignClient;
import cn.nine.pros.post.client.model.db.ImConversationDTO;
import org.springframework.stereotype.Service;

/**
 * IM会话表（腾讯IM） FeignResource
 *
 * @author Administrator
 */
@Service
public class ImConversationFeignResource extends AbstractMybatisFeignClient<Long, ImConversationDomain, ImConversationDTO,
        ImConversationMapstruct> implements ImConversationFeignClient {


}