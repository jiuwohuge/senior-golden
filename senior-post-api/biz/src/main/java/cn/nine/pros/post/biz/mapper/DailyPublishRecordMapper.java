package cn.nine.pros.post.biz.mapper;

import cn.nine.pros.post.biz.model.domain.DailyPublishRecordDomain;
import org.apache.ibatis.annotations.Mapper;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;

/**
 * 每日发布记录表 Mapper
 *
 * @author Administrator
 */
@Mapper
public interface DailyPublishRecordMapper extends BaseMapper<DailyPublishRecordDomain> {

}
