package cn.nine.pros.post.client.model.input.admin;

import cn.nine.commons.data.dto.AbstractDTO;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 管理端调整用户当日免费发信剩余额度。
 */
@Data
@EqualsAndHashCode(callSuper = true)
@Schema(description = "调整当日免费额度入参")
public class AdminUserQuotaAdjustInDto extends AbstractDTO {

    @NotNull
    @Min(0)
    @Schema(description = "调整后的当日剩余次数（≥0）", requiredMode = Schema.RequiredMode.REQUIRED)
    private Integer remainingQuota;
}
