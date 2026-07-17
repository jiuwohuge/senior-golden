package cn.nine.pros.post.biz.service.clients.impl;

import cn.nine.commons.feign.bridge.mybatis.AbstractMybatisFeignClient;
import cn.nine.pros.post.biz.model.domain.LetterDomain;
import cn.nine.pros.post.biz.model.mapstruct.LetterMapstruct;
import cn.nine.pros.post.biz.service.clients.LetterFeignClient;
import cn.nine.pros.post.client.model.db.LetterDTO;
import org.springframework.stereotype.Service;

/**
 * 信件表 FeignResource
 *
 * @author Administrator
 */
@Service
public class LetterFeignResource extends AbstractMybatisFeignClient<Long, LetterDomain, LetterDTO,
        LetterMapstruct> implements LetterFeignClient {


}