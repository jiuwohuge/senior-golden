package cn.nine.pros.post.client.model.out;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Builder
@Schema(description = "封缄结果")
public class TimeLetterSealResultVO {

    private Long id;
    private Integer status;
    private LocalDate deliveryDate;
    private LocalDateTime cancelDeadlineAt;
    private Integer stampCost;
    private Integer stampBalanceAfter;
}
