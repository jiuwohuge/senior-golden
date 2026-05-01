package cn.nine.pros.post.biz.service.clients.impl;

import cn.nine.commons.feign.bridge.mybatis.AbstractMybatisFeignClient;
import cn.nine.pros.post.biz.model.domain.AppVersionDomain;
import cn.nine.pros.post.biz.model.mapstruct.AppVersionMapstruct;
import cn.nine.pros.post.biz.service.clients.AppVersionFeignClient;
import cn.nine.pros.post.client.model.db.AppVersionDTO;
import org.springframework.stereotype.Service;

/**
 * App版本控制表 FeignResource
 *
 * @author Administrator
 */
@Service
public class AppVersionFeignResource extends AbstractMybatisFeignClient<Integer, AppVersionDomain, AppVersionDTO,
        AppVersionMapstruct> implements AppVersionFeignClient {


}