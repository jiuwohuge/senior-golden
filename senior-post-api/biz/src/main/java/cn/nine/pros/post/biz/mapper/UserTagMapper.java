package cn.nine.pros.post.biz.mapper;

import cn.nine.pros.post.biz.model.domain.UserTagDomain;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 用户兴趣标签关联表 Mapper
 *
 * @author Administrator
 */
@Mapper
public interface UserTagMapper extends BaseMapper<UserTagDomain> {

    /** 含已逻辑删除行，便于兴趣标签再次勾选时恢复。 */
    @Select("SELECT * FROM bu_user_tag WHERE user_id = #{userId}")
    List<UserTagDomain> selectAllByUserIdIncludingDeleted(@Param("userId") long userId);

    @Update("UPDATE bu_user_tag SET del_flag = false, updated_at = #{updatedAt}, updated_by = #{updatedBy} WHERE id = #{id}")
    int restoreById(
            @Param("id") Long id,
            @Param("updatedAt") LocalDateTime updatedAt,
            @Param("updatedBy") Long updatedBy);

}
