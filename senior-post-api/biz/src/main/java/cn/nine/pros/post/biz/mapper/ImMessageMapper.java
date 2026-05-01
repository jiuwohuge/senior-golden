package cn.nine.pros.post.biz.mapper;

import cn.nine.pros.post.biz.model.domain.ImMessageDomain;
import org.apache.ibatis.annotations.Mapper;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;

/**
 * IM消息表 Mapper
 *
 * @author Administrator
 */
@Mapper
public interface ImMessageMapper extends BaseMapper<ImMessageDomain> {

}
