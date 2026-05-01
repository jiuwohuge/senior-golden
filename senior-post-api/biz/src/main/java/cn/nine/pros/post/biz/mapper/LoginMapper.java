package cn.nine.pros.post.biz.mapper;

import cn.nine.pros.post.biz.model.domain.LoginDomain;
import org.apache.ibatis.annotations.Mapper;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;

/**
 * 登录日志表 Mapper
 *
 * @author Administrator
 */
@Mapper
public interface LoginMapper extends BaseMapper<LoginDomain> {

}
