package cn.nine.pros.post.client.model.db;

import cn.nine.commons.data.dto.AbstractAuditableDTO;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

/**
 * VIP订阅记录表 DTO
 *
 * @author Administrator
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
public class VipSubscriptionDTO extends AbstractAuditableDTO {

    private static final long serialVersionUID = 1L;

    /**
     * 订阅ID
     */
    @Schema(description = "订阅ID")
    private Long id;
    /**
     * 用户ID
     */
    @Schema(description = "用户ID")
    private Long userId;
    /**
     * 套餐标识
     */
    @Schema(description = "套餐标识")
    private String planId;
    /**
     * 生效开始时间
     */
    @Schema(description = "生效开始时间")
    private Object startAt;
    /**
     * 生效结束时间
     */
    @Schema(description = "生效结束时间")
    private Object endAt;
    /**
     * 状态：1有效 2过期 3取消
     */
    @Schema(description = "状态：1有效 2过期 3取消")
    private Object status;

}