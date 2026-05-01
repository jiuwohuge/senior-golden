package cn.nine.pros.post.biz.mapper;

import cn.nine.pros.post.biz.model.domain.SensitiveWordDomain;
import org.apache.ibatis.annotations.Mapper;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;

/**
 * 敏感词库表 Mapper
 *
 * @author Administrator
 */
@Mapper
public interface SensitiveWordMapper extends BaseMapper<SensitiveWordDomain> {

}
