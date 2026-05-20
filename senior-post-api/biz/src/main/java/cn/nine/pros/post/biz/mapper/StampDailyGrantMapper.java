package cn.nine.pros.post.biz.mapper;

import cn.nine.pros.post.biz.model.domain.StampDailyGrantDomain;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.time.LocalDate;

@Mapper
public interface StampDailyGrantMapper extends BaseMapper<StampDailyGrantDomain> {

    @Insert("""
            INSERT INTO bu_stamp_daily_grant (user_id, grant_day, grant_kind, ref_id, amount, created_at)
            VALUES (#{userId}, #{grantDay}, #{grantKind}, #{refId}, #{amount}, #{createdAt})
            ON CONFLICT (user_id, grant_day) WHERE grant_kind = 'LOGIN' DO NOTHING
            """)
    int insertLoginGrantIgnoreConflict(StampDailyGrantDomain row);

    @Insert("""
            INSERT INTO bu_stamp_daily_grant (user_id, grant_day, grant_kind, ref_id, amount, created_at)
            VALUES (#{userId}, #{grantDay}, #{grantKind}, #{refId}, #{amount}, #{createdAt})
            ON CONFLICT (user_id, ref_id) WHERE grant_kind = 'POSTCARD' DO NOTHING
            """)
    int insertPostcardGrantIgnoreConflict(StampDailyGrantDomain row);

    @Select("""
            SELECT COALESCE(SUM(amount), 0)
            FROM bu_stamp_daily_grant
            WHERE user_id = #{userId}
              AND grant_day = #{grantDay}
              AND grant_kind = 'POSTCARD'
            """)
    int sumPostcardAmountForDay(@Param("userId") long userId, @Param("grantDay") LocalDate grantDay);
}
