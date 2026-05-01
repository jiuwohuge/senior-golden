package cn.nine.pros.post.biz.mapper;

import cn.nine.pros.post.biz.model.domain.ImConversationDomain;
import org.apache.ibatis.annotations.Mapper;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;

/**
 * IM会话表（腾讯IM） Mapper
 *
 * @author Administrator
 */
@Mapper
public interface ImConversationMapper extends BaseMapper<ImConversationDomain> {

}
