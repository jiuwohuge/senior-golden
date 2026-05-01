package cn.nine.pros.post.biz.mapper;

import cn.nine.pros.post.biz.model.domain.UserBlacklistDomain;
import org.apache.ibatis.annotations.Mapper;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;

/**
 * 用户黑名单表 Mapper
 *
 * @author Administrator
 */
@Mapper
public interface UserBlacklistMapper extends BaseMapper<UserBlacklistDomain> {

}
