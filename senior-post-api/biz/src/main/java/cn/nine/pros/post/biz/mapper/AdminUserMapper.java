package cn.nine.pros.post.biz.mapper;

import cn.nine.pros.post.biz.model.domain.AdminUserDomain;
import org.apache.ibatis.annotations.Mapper;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;

/**
 * 管理员表 Mapper
 *
 * @author Administrator
 */
@Mapper
public interface AdminUserMapper extends BaseMapper<AdminUserDomain> {

}
