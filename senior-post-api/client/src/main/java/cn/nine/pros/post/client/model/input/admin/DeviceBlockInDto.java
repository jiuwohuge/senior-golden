package cn.nine.pros.post.client.model.input.admin;

import cn.nine.commons.data.dto.AbstractDTO;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@Schema(description = "设备拉黑入参")
public class DeviceBlockInDto extends AbstractDTO {

    @NotBlank(message = "设备UUID不能为空")
    @Schema(description = "设备UUID")
    private String deviceUuid;

    @Schema(description = "拉黑原因")
    private String reason;
}