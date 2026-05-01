package cn.nine.pros.post.client.model.input.admin;

import cn.nine.commons.data.dto.AbstractDTO;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@Schema(description = "配置创建/更新入参")
public class ConfigInDto extends AbstractDTO {

    @Schema(description = "配置ID（更新时传入）")
    private Integer id;

    @NotBlank(message = "配置键不能为空")
    @Schema(description = "配置键")
    private String configKey;

    @NotBlank(message = "配置值不能为空")
    @Schema(description = "配置值")
    private String configValue;

    @NotBlank(message = "配置分组不能为空")
    @Schema(description = "配置分组（register/vip/stamps/system等）")
    private String configGroup;

    @Schema(description = "配置描述")
    private String description;
}