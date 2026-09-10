package cn.nine.pros.post.client.model.input.app;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
@Schema(description = "在途改信入参")
public class InTransitLetterEditInDto {

    @NotBlank
    @Schema(description = "新正文", requiredMode = Schema.RequiredMode.REQUIRED)
    private String content;
}
