package cn.nine.pros.post.biz.model.domain;

import cn.nine.commons.data.domain.AbstractAuditableDomain;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

/**
 * 邮票变更流水日志 Domain
 *
 * @author Administrator
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
@TableName("log_stamp_transaction")
public class StampTransactionDomain extends AbstractAuditableDomain {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    @Schema(description = "流水ID")
    private Long id;
    /**
     * 用户ID
     */
    @Schema(description = "用户ID")
    private Long userId;
    /**
     * 变更数量（正增负减）
     */
    @Schema(description = "变更数量（正增负减）")
    private Integer changeAmount;
    /**
     * 变更后余额
     */
    @Schema(description = "变更后余额")
    private Integer balanceAfter;
    /**
     * 变更原因（登录奖励/发布明信片/挂号信消耗/加速消耗）
     */
    @Schema(description = "变更原因（登录奖励/发布明信片/挂号信消耗/加速消耗）")
    private String reason;
    /**
     * 关联业务ID（明信片ID/信件ID）
     */
    @Schema(description = "关联业务ID（明信片ID/信件ID）")
    private Long refId;

}