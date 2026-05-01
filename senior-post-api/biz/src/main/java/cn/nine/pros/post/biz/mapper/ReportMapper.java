package cn.nine.pros.post.biz.mapper;

import cn.nine.pros.post.biz.model.domain.ReportDomain;
import org.apache.ibatis.annotations.Mapper;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;

/**
 * 举报工单表 Mapper
 *
 * @author Administrator
 */
@Mapper
public interface ReportMapper extends BaseMapper<ReportDomain> {

}
