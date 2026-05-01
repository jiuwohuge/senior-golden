package cn.nine.pros.post.client.model.input.admin;

import cn.nine.commons.data.dto.AbstractDTO;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@Schema(description = "内容驳回归参")
public class ContentRejectInDto extends AbstractDTO {

    @NotBlank(message = "驳回原因不能为空")
    @Schema(description = "驳回原因")
    private String reason;
}