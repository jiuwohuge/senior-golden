package cn.nine.pros.post.client.model.input.admin;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
@Schema(description = "时光信下架")
public class TimeLetterTakedownInDto {

    @NotBlank
    @Schema(description = "下架原因")
    private String reason;
}
