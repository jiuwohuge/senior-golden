package cn.nine.pros.post.client.model.db;

import cn.nine.commons.data.dto.AbstractAuditableDTO;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

/**
 * 邮票变更流水日志 DTO
 *
 * @author Administrator
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
public class StampTransactionDTO extends AbstractAuditableDTO {

    private static final long serialVersionUID = 1L;

    /**
     * 流水ID
     */
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