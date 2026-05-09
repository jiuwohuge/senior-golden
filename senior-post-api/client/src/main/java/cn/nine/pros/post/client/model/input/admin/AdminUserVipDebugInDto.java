package cn.nine.pros.post.client.model.input.admin;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDateTime;
import lombok.Data;

/** 管理端调试：直接修改用户 VIP 标记与过期时间（非订阅支付）。 */
@Data
@Schema(description = "调试修改用户 VIP")
public class AdminUserVipDebugInDto {

    @NotNull
    @Schema(description = "是否 VIP", requiredMode = Schema.RequiredMode.REQUIRED)
    private Boolean isVip;

    @Schema(description = "VIP 过期时间；null 表示不修改该字段（保持原值）")
    private LocalDateTime vipExpireAt;

    @Schema(description = "为 true 时将 vip_expire_at 置为 null（长期有效）")
    private Boolean clearVipExpireAt;
}
