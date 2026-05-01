package cn.nine.pros.post.biz.service.clients.impl;

import cn.nine.commons.feign.bridge.mybatis.AbstractMybatisFeignClient;
import cn.nine.pros.post.biz.model.domain.AnnouncementDomain;
import cn.nine.pros.post.biz.model.mapstruct.AnnouncementMapstruct;
import cn.nine.pros.post.biz.service.clients.AnnouncementFeignClient;
import cn.nine.pros.post.client.model.db.AnnouncementDTO;
import org.springframework.stereotype.Service;

/**
 * 系统公告表 FeignResource
 *
 * @author Administrator
 */
@Service
public class AnnouncementFeignResource extends AbstractMybatisFeignClient<Integer, AnnouncementDomain, AnnouncementDTO,
        AnnouncementMapstruct> implements AnnouncementFeignClient {


}