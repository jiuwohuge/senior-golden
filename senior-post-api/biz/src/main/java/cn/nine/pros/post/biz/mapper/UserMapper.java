package cn.nine.pros.post.biz.mapper;

import cn.nine.pros.post.biz.model.domain.UserDomain;
import org.apache.ibatis.annotations.Mapper;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;

/**
 * 用户主表 Mapper
 *
 * @author Administrator
 */
@Mapper
public interface UserMapper extends BaseMapper<UserDomain> {

}
