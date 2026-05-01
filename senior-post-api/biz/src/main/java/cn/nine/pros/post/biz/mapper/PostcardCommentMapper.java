package cn.nine.pros.post.biz.mapper;

import cn.nine.pros.post.biz.model.domain.PostcardCommentDomain;
import org.apache.ibatis.annotations.Mapper;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;

/**
 * 明信片评论表 Mapper
 *
 * @author Administrator
 */
@Mapper
public interface PostcardCommentMapper extends BaseMapper<PostcardCommentDomain> {

}
