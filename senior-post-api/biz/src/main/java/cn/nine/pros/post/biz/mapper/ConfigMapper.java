package cn.nine.pros.post.biz.mapper;

import cn.nine.pros.post.biz.model.domain.ConfigDomain;
import org.apache.ibatis.annotations.Mapper;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;

/**
 * 系统配置表 Mapper
 *
 * @author Administrator
 */
@Mapper
public interface ConfigMapper extends BaseMapper<ConfigDomain> {

}
