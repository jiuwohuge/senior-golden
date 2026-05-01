package cn.nine.pros.post.biz.mapper;

import cn.nine.pros.post.biz.model.domain.ExceptionDomain;
import org.apache.ibatis.annotations.Mapper;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;

/**
 * 系统异常日志表 Mapper
 *
 * @author Administrator
 */
@Mapper
public interface ExceptionMapper extends BaseMapper<ExceptionDomain> {

}
