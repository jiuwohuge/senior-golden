package cn.nine.pros.post.biz.mapper;

import cn.nine.pros.post.biz.model.domain.LetterDomain;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 信件表（挂号信/平邮） Mapper
 *
 * @author Administrator
 */
@Mapper
public interface LetterMapper extends BaseMapper<LetterDomain> {

    @Select({
            "<script>",
            "SELECT COUNT(1) FROM bu_letter WHERE del_flag = false ",
            "AND (",
            "#{viewerId} = #{ownerId} ",
            "OR (",
            "((from_user_id = #{viewerId} AND to_user_id = #{ownerId}) ",
            "OR (from_user_id = #{ownerId} AND to_user_id = #{viewerId})) ",
            "<if test='variants != null and variants.size() &gt; 0'>",
            "AND (",
            "<foreach collection='variants' item='v' separator=' OR '>",
            "content LIKE CONCAT('%', #{v}, '%')",
            "</foreach>",
            ")",
            "</if>",
            "<if test='variants == null or variants.size() == 0'>",
            "AND 1 = 0",
            "</if>",
            ")",
            ")",
            "</script>",
    })
    long countPeerLetterReferencingContent(
            @Param("viewerId") long viewerId,
            @Param("ownerId") long ownerId,
            @Param("variants") List<String> variants);
}
