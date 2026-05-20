package cn.nine.pros.post.biz.mapper;

import cn.nine.pros.post.biz.model.domain.UserIdentityDomain;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface UserIdentityMapper extends BaseMapper<UserIdentityDomain> {
}
