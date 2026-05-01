package cn.nine.pros.post.biz.mapper;

import cn.nine.pros.post.biz.model.domain.AppVersionDomain;
import org.apache.ibatis.annotations.Mapper;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;

/**
 * App版本控制表 Mapper
 *
 * @author Administrator
 */
@Mapper
public interface AppVersionMapper extends BaseMapper<AppVersionDomain> {

}
