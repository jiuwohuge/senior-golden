package cn.nine.pros.post.biz.mapper;

import cn.nine.pros.post.biz.model.domain.AnnouncementDomain;
import org.apache.ibatis.annotations.Mapper;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;

/**
 * 系统公告表 Mapper
 *
 * @author Administrator
 */
@Mapper
public interface AnnouncementMapper extends BaseMapper<AnnouncementDomain> {

}
