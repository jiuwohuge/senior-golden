package cn.nine.pros.post.biz.model.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 邮票赠送幂等记录（UTC 日切）。
 */
@Data
@TableName("bu_stamp_daily_grant")
public class StampDailyGrantDomain implements Serializable {

    private static final long serialVersionUID = 1L;

    public static final String KIND_LOGIN = "LOGIN";
    public static final String KIND_POSTCARD = "POSTCARD";

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long userId;

    private LocalDate grantDay;

    /** {@link #KIND_LOGIN} / {@link #KIND_POSTCARD} */
    private String grantKind;

    /** 明信片 ID（POSTCARD 时必填） */
    private Long refId;

    private Integer amount;

    private LocalDateTime createdAt;
}
