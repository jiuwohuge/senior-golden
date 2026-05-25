package cn.nine.pros.post.client.model.input.admin;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
@Schema(description = "保存明信片机审开关")
public class ModerationConfigSaveInDto {

    @NotNull
    @Schema(description = "明信片配图鉴黄开关")
    private Boolean postcardImageEnabled;

    @NotNull
    @Schema(description = "明信片正文鉴黄开关")
    private Boolean postcardTextEnabled;
}
