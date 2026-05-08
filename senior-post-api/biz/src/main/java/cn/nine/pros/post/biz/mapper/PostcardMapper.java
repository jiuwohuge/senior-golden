package cn.nine.pros.post.biz.mapper;

import cn.nine.pros.post.biz.model.domain.PostcardDomain;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 明信片墙表（用户发布的公开明信片） Mapper
 *
 * @author Administrator
 */
@Mapper
public interface PostcardMapper extends BaseMapper<PostcardDomain> {

    @Select({
            "<script>",
            "SELECT COUNT(1) FROM bu_postcard WHERE del_flag = false ",
            "AND ((review_status = 1 AND status = 1) OR user_id = #{viewerId}) ",
            "AND (",
            "<foreach collection='variants' item='v' separator=' OR '>",
            "(main_image_url = #{v} OR COALESCE(images, '') LIKE CONCAT('%', #{v}, '%'))",
            "</foreach>",
            ")",
            "</script>",
    })
    long countVisibleReferencingImage(@Param("viewerId") long viewerId, @Param("variants") List<String> variants);
}
