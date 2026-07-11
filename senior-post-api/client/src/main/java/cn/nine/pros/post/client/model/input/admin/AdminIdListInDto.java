package cn.nine.pros.post.client.model.input.admin;

import cn.nine.commons.data.dto.AbstractDTO;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotEmpty;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.util.List;

@Data
@EqualsAndHashCode(callSuper = true)
@Schema(description = "ID 列表入参")
public class AdminIdListInDto extends AbstractDTO {

    @NotEmpty
    @Schema(description = "ID 列表", requiredMode = Schema.RequiredMode.REQUIRED)
    private List<Long> ids;
}
