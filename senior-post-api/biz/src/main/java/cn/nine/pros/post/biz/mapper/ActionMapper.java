package cn.nine.pros.post.biz.mapper;

import cn.nine.pros.post.biz.model.domain.ActionDomain;
import org.apache.ibatis.annotations.Mapper;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;

/**
 * 用户行为日志（发布/寄信/加速等） Mapper
 *
 * @author Administrator
 */
@Mapper
public interface ActionMapper extends BaseMapper<ActionDomain> {

}
