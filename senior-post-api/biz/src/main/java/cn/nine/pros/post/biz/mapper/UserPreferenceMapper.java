package cn.nine.pros.post.biz.mapper;

import cn.nine.pros.post.biz.model.domain.UserPreferenceDomain;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface UserPreferenceMapper extends BaseMapper<UserPreferenceDomain> {
}
