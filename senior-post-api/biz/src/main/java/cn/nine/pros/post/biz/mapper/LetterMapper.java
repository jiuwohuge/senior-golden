package cn.nine.pros.post.biz.mapper;

import cn.nine.pros.post.biz.model.domain.LetterDomain;
import org.apache.ibatis.annotations.Mapper;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;

/**
 * 信件表（挂号信/平邮） Mapper
 *
 * @author Administrator
 */
@Mapper
public interface LetterMapper extends BaseMapper<LetterDomain> {

}
