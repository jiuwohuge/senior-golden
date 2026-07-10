package cn.nine.pros.post.client.model.input.admin;

import cn.nine.commons.data.dto.AbstractDTO;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@Schema(description = "管理端手动发放权益")
public class AdminCommerceGrantInDto extends AbstractDTO {

    @NotNull
    @Schema(description = "用户 ID", requiredMode = Schema.RequiredMode.REQUIRED)
    private Long userId;

    @NotNull
    @Schema(description = "商品 ID", requiredMode = Schema.RequiredMode.REQUIRED)
    private Long productId;
}
