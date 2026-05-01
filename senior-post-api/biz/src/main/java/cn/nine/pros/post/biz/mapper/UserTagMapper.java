package cn.nine.pros.post.biz.mapper;

import cn.nine.pros.post.biz.model.domain.UserTagDomain;
import org.apache.ibatis.annotations.Mapper;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;

/**
 * 用户兴趣标签关联表 Mapper
 *
 * @author Administrator
 */
@Mapper
public interface UserTagMapper extends BaseMapper<UserTagDomain> {

}
