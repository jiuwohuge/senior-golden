package cn.nine.pros.post.biz.model.domain;

import cn.nine.commons.data.domain.AbstractAuditableDomain;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

/**
 * 邮政建联后的好友关系（与腾讯 IM C2C 配对）。
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
@TableName("bu_friendship")
public class FriendshipDomain extends AbstractAuditableDomain {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    @Schema(description = "好友关系ID")
    private Long id;

    @Schema(description = "较小用户ID")
    private Long userLow;

    @Schema(description = "较大用户ID")
    private Long userHigh;

    /**
     * 1=active
     */
    @Schema(description = "1=active")
    private Integer status;

    @Schema(description = "触发建联的信件ID")
    private Long sourceLetterId;
}
