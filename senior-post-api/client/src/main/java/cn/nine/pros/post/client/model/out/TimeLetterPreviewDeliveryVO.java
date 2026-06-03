package cn.nine.pros.post.client.model.out;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDate;

@Data
@Builder
@Schema(description = "送达日预览")
public class TimeLetterPreviewDeliveryVO {

    private LocalDate deliveryDate;
    private String deliveryTz;
    private int daysUntilDelivery;
    private boolean valid;
    private String message;
}
