package cn.nine.pros.post.biz.mapper;

import cn.nine.pros.post.biz.model.domain.VisitorRecordDomain;
import org.apache.ibatis.annotations.Mapper;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;

/**
 * 访客记录表 Mapper
 *
 * @author Administrator
 */
@Mapper
public interface VisitorRecordMapper extends BaseMapper<VisitorRecordDomain> {

}
