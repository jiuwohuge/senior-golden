package cn.nine.pros.post.client.model.input.app;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
@Schema(description = "模拟购买入参")
public class CommerceMockPurchaseInDto {

    @NotNull
    @Schema(description = "商品 ID", requiredMode = Schema.RequiredMode.REQUIRED)
    private Long productId;
}
