package cn.nine.pros.post.biz.model.domain;

import cn.nine.commons.data.domain.AbstractAuditableDomain;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

/**
 * VIP订阅记录表 Domain
 *
 * @author Administrator
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
@TableName("bu_vip_subscription")
public class VipSubscriptionDomain extends AbstractAuditableDomain {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
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