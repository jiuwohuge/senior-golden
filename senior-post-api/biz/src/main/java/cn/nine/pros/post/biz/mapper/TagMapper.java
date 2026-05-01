package cn.nine.pros.post.biz.mapper;

import cn.nine.pros.post.biz.model.domain.TagDomain;
import org.apache.ibatis.annotations.Mapper;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;

/**
 * 兴趣标签表 Mapper
 *
 * @author Administrator
 */
@Mapper
public interface TagMapper extends BaseMapper<TagDomain> {

}
