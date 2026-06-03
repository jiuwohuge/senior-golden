package cn.nine.pros.post.client.model.input.app;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDate;

@Data
@Schema(description = "送达日预览")
public class TimeLetterPreviewDeliveryInDto {

    @Schema(description = "送达日期")
    private LocalDate deliveryDate;

    @Schema(description = "送达时区 IANA ID")
    private String deliveryTz;
}
