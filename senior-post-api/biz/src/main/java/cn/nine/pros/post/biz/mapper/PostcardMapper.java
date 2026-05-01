package cn.nine.pros.post.biz.mapper;

import cn.nine.pros.post.biz.model.domain.PostcardDomain;
import org.apache.ibatis.annotations.Mapper;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;

/**
 * 明信片墙表（用户发布的公开明信片） Mapper
 *
 * @author Administrator
 */
@Mapper
public interface PostcardMapper extends BaseMapper<PostcardDomain> {

}
