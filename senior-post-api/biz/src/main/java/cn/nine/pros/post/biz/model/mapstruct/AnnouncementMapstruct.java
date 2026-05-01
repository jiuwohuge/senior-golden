package cn.nine.pros.post.biz.model.mapstruct;

import cn.nine.commons.feign.bridge.core.CommonMapper;
import cn.nine.pros.post.biz.model.domain.AnnouncementDomain;
import cn.nine.pros.post.client.model.db.AnnouncementDTO;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

/**
 * 系统公告表 Mapper
 *
 * @author Administrator
 */
@Mapper(componentModel = "spring")
public interface AnnouncementMapstruct extends CommonMapper<AnnouncementDomain, AnnouncementDTO> {

    AnnouncementMapstruct INSTANCE = Mappers.getMapper(AnnouncementMapstruct.class);

}