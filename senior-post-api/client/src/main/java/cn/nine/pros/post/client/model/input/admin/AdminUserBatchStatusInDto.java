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
@Schema(description = "用户批量改状态")
public class AdminUserBatchStatusInDto extends AbstractDTO {

    @NotEmpty
    @Schema(description = "用户 ID 列表", requiredMode = Schema.RequiredMode.REQUIRED)
    private List<Long> ids;

    @NotNull
    @Schema(description = "目标状态：1正常 2封禁 3注销", requiredMode = Schema.RequiredMode.REQUIRED)
    private Integer status;
}
