package cn.nine.pros.post.client.model.input.admin;

import cn.nine.commons.data.dto.AbstractDTO;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.util.List;

@Data
@EqualsAndHashCode(callSuper = true)
@Schema(description = "商品批量改状态")
public class AdminCommerceProductBatchStatusInDto extends AbstractDTO {

    @NotEmpty
    @Schema(description = "商品 ID 列表", requiredMode = Schema.RequiredMode.REQUIRED)
    private List<Long> ids;

    @NotNull
    @Schema(description = "目标状态", requiredMode = Schema.RequiredMode.REQUIRED)
    private Integer status;
}
