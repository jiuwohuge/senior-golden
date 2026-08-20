package cn.nine.pros.post.biz.mapper;

import cn.nine.pros.post.biz.model.domain.UserBlacklistDomain;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;

import java.time.LocalDateTime;

/**
 * 用户黑名单表 Mapper
 *
 * @author Administrator
 */
@Mapper
public interface UserBlacklistMapper extends BaseMapper<UserBlacklistDomain> {

    /** 含已逻辑删除行，便于再次拉黑时恢复原记录。 */
    @Select("SELECT * FROM bu_user_blacklist WHERE user_id = #{userId} AND blocked_user_id = #{blockedUserId} LIMIT 1")
    UserBlacklistDomain selectByPairIncludingDeleted(
            @Param("userId") long userId, @Param("blockedUserId") long blockedUserId);

    /** updateById 带 TableLogic，无法把已删行改回未删。 */
    @Update("UPDATE bu_user_blacklist SET del_flag = false, reason = #{reason}, "
            + "updated_at = #{updatedAt}, updated_by = #{updatedBy} WHERE id = #{id}")
    int restoreById(
            @Param("id") Long id,
            @Param("reason") String reason,
            @Param("updatedAt") LocalDateTime updatedAt,
            @Param("updatedBy") Long updatedBy);

}
