package cn.nine.pros.post.client.model.input.app;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
@Schema(description = "Play 购买校验入参")
public class PlayPurchaseVerifyInDto {

    @NotBlank
    @Schema(description = "Play purchaseToken", requiredMode = Schema.RequiredMode.REQUIRED)
    private String purchaseToken;

    @NotBlank
    @Schema(description = "plus_monthly | plus_yearly", requiredMode = Schema.RequiredMode.REQUIRED)
    private String productId;

    @Schema(description = "Play orderId")
    private String orderId;

    @Schema(description = "应用包名；非空时须与服务端配置一致")
    private String packageName;

    @Schema(description = "客户端是否已 acknowledge")
    private Boolean acknowledged;

    @Schema(description = "年订试用：true 时 end_at=now+7d 且 is_trial=true")
    private Boolean isTrial;
}
