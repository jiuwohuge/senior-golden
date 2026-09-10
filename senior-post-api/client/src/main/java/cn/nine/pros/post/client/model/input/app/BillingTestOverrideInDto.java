package cn.nine.pros.post.client.model.input.app;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
@Schema(description = "本地/分身侧订阅状态覆盖（仅 test-override-enabled）")
public class BillingTestOverrideInDto {

    @NotBlank
    @Schema(description = "none|trial|active|expired", requiredMode = Schema.RequiredMode.REQUIRED)
    private String state;

    @Schema(description = "plus_monthly | plus_yearly；默认 plus_yearly")
    private String productId;
}
